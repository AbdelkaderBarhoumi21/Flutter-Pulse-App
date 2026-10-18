import 'package:flutter_pulse_app/core/constants/app_limits.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_priority.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_stats.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';
import 'package:flutter_pulse_app/features/task/domain/validators/task_validator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/task_factory.dart';

void main() {
  group('TaskValidator', () {
    test('title rules', () {
      expect(TaskValidator.validateTitle(null), AppStrings.titleRequired);
      expect(TaskValidator.validateTitle('   '), AppStrings.titleRequired);
      expect(TaskValidator.validateTitle('ab'), AppStrings.titleTooShort);
      expect(
        TaskValidator.validateTitle('a' * (AppLimits.maxTitleLength + 1)),
        AppStrings.titleTooLong,
      );
      expect(TaskValidator.validateTitle('  Buy milk  '), isNull);
    });

    test('description rules', () {
      expect(TaskValidator.validateDescription(null), isNull);
      expect(TaskValidator.validateDescription(''), isNull);
      expect(
        TaskValidator.validateDescription(
          'a' * (AppLimits.maxDescriptionLength + 1),
        ),
        AppStrings.descriptionTooLong,
      );
    });

    test('id and content', () {
      expect(TaskValidator.validateId(' '), AppStrings.taskIdRequired);
      expect(TaskValidator.validateId('1'), isNull);
      expect(
        TaskValidator.validateContent(buildTask(title: '')),
        AppStrings.titleRequired,
      );
      expect(TaskValidator.validateContent(buildTask()), isNull);
    });
  });

  group('TaskEntity', () {
    test('draft is pending with no id', () {
      final draft = TaskEntity.draft(
        title: 'New',
        description: '',
        priority: TaskPriority.high,
        now: testNow,
      );
      expect(draft.id, isEmpty);
      expect(draft.status, TaskStatus.pending);
      expect(draft.createdAt, testNow);
    });

    test('withStatus stamps and clears completedAt', () {
      final done = buildTask().withStatus(TaskStatus.completed, now: testNow);
      expect(done.isCompleted, isTrue);
      expect(done.completedAt, testNow);

      final reopened = done.withStatus(TaskStatus.inProgress, now: testNow);
      expect(reopened.completedAt, isNull);
    });

    test('withStatus to the same status is a no-op', () {
      final task = buildTask(status: TaskStatus.inProgress);
      expect(task.withStatus(TaskStatus.inProgress, now: testNow), same(task));
    });

    test('copyWith can clear completedAt explicitly', () {
      final task = buildTask(completedAt: testNow);
      expect(task.copyWith(completedAt: () => null).completedAt, isNull);
      expect(task.copyWith(title: 'x').completedAt, testNow);
    });
  });

  test('TaskStats counts per status', () {
    final stats = TaskStats.fromTasks([
      buildTask(id: '1'),
      buildTask(id: '2', status: TaskStatus.inProgress),
      buildTask(id: '3', status: TaskStatus.completed),
      buildTask(id: '4', status: TaskStatus.completed),
    ]);
    expect(stats.total, 4);
    expect(stats.countOf(TaskStatus.completed), 2);
    expect(stats.progress, 0.5);
    expect(TaskStats.fromTasks(const []).progress, 0);
  });
}
