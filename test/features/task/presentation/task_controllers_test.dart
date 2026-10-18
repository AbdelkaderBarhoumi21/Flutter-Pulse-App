import 'dart:async';

import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/utils/clock_provider.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_priority.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';
import 'package:flutter_pulse_app/features/task/presentation/models/task_filter.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_details_controller.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_filter_controller.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_list_controller.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_list_selectors.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/task_factory.dart';

void main() {
  late FakeTaskRepository repository;
  late ProviderContainer container;

  final first = buildTask(id: '1', title: 'First task');
  final second = buildTask(id: '2', title: 'Second task');

  setUp(() {
    repository = FakeTaskRepository([first, second]);
    container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => testNow),
      ],
    );
    addTearDown(container.dispose);
  });

  TaskListController controller() =>
      container.read(taskListControllerProvider.notifier);

  List<String> ids() => container
      .read(taskListControllerProvider)
      .requireValue
      .map((t) => t.id)
      .toList();

  group('TaskListController', () {
    test('loads the tasks', () async {
      await container.read(taskListControllerProvider.future);
      expect(ids(), ['1', '2']);
    });

    test('create inserts the saved task on top', () async {
      await container.read(taskListControllerProvider.future);
      final result = await controller().create(
        title: 'Brand new',
        description: '',
        priority: TaskPriority.high,
      );
      expect(result.isRight(), isTrue);
      expect(ids().first, startsWith('new-'));
    });

    test('toggleCompleted completes and reopens', () async {
      await container.read(taskListControllerProvider.future);

      await controller().toggleCompleted(first);
      final done = container
          .read(taskListControllerProvider)
          .requireValue
          .first;
      expect(done.status, TaskStatus.completed);
      expect(done.completedAt, testNow);

      await controller().toggleCompleted(done);
      final reopened = container
          .read(taskListControllerProvider)
          .requireValue
          .first;
      expect(reopened.status, TaskStatus.pending);
      expect(reopened.completedAt, isNull);
    });

    test('delete removes optimistically, before the server answers', () async {
      await container.read(taskListControllerProvider.future);
      repository.gate = Completer<void>();

      final pending = controller().delete('1');
      expect(ids(), ['2']);

      repository.gate!.complete();
      expect((await pending).isRight(), isTrue);
      expect(ids(), ['2']);
    });

    // Regression: a failed mutation used to replace the whole list with an
    // error screen.
    test('a failed delete rolls back and keeps the list', () async {
      await container.read(taskListControllerProvider.future);
      repository.failure = const NetworkFailure();

      final result = await controller().delete('1');

      expect(result.isLeft(), isTrue);
      expect(container.read(taskListControllerProvider).hasError, isFalse);
      expect(ids(), ['1', '2']);
    });

    test('a failed status change rolls back', () async {
      await container.read(taskListControllerProvider.future);
      repository.failure = const ServerFailure();

      await controller().toggleCompleted(first);

      expect(
        container.read(taskListControllerProvider).requireValue.first.status,
        TaskStatus.pending,
      );
    });

    test('a failed refresh keeps the current data', () async {
      await container.read(taskListControllerProvider.future);
      repository.failure = const NetworkFailure();

      final result = await controller().refresh();

      expect(result.isLeft(), isTrue);
      expect(ids(), ['1', '2']);
    });

    test('refresh after an initial error recovers', () async {
      repository.failure = const NetworkFailure();
      await expectLater(
        container.read(taskListControllerProvider.future),
        throwsA(isA<NetworkFailure>()),
      );

      repository.failure = null;
      await controller().refresh();
      expect(ids(), ['1', '2']);
    });

    test('concurrent refreshes share one request', () async {
      await container.read(taskListControllerProvider.future);
      final callsBefore = repository.getTasksCalls;

      await Future.wait([controller().refresh(), controller().refresh()]);

      expect(repository.getTasksCalls, callsBefore + 1);
    });
  });

  group('selectors', () {
    test('filter and stats', () async {
      await container.read(taskListControllerProvider.future);
      await controller().toggleCompleted(second);

      container
          .read(taskFilterControllerProvider.notifier)
          .select(TaskFilter.completed);

      expect(container.read(visibleTasksProvider).map((t) => t.id), ['2']);
      expect(container.read(taskStatsProvider).completed, 1);
      expect(container.read(taskStatsProvider).total, 2);
    });
  });

  group('TaskDetailsController', () {
    test('serves the cached task instantly, then revalidates', () async {
      await container.read(taskListControllerProvider.future);
      final sub = container.listen(
        taskDetailsControllerProvider('1'),
        (_, _) {},
      );
      addTearDown(sub.close);

      expect(
        await container.read(taskDetailsControllerProvider('1').future),
        first,
      );
      await pumpEventQueue();
      expect(repository.getTaskByIdCalls, 1);
    });

    test('fetches by id when the list has not loaded (deep link)', () async {
      final sub = container.listen(
        taskDetailsControllerProvider('2'),
        (_, _) {},
      );
      addTearDown(sub.close);

      final task = await container.read(
        taskDetailsControllerProvider('2').future,
      );
      expect(task.title, 'Second task');
    });

    test('follows changes made through the list', () async {
      await container.read(taskListControllerProvider.future);
      final sub = container.listen(
        taskDetailsControllerProvider('1'),
        (_, _) {},
      );
      addTearDown(sub.close);
      await container.read(taskDetailsControllerProvider('1').future);

      await controller().toggleCompleted(first);

      expect(
        container.read(taskDetailsControllerProvider('1')).requireValue.status,
        TaskStatus.completed,
      );
    });

    test('a missing task is an error state', () async {
      final sub = container.listen(
        taskDetailsControllerProvider('404'),
        (_, _) {},
      );
      addTearDown(sub.close);

      await expectLater(
        container.read(taskDetailsControllerProvider('404').future),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
