import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/extensions/appearance_mode_extensions.dart';
import 'package:flutter_pulse_app/core/routing/app_router.dart';
import 'package:flutter_pulse_app/core/routing/app_routes.dart';
import 'package:flutter_pulse_app/features/settings/domain/entities/appearance_mode.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_card.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_check_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_task_repository.dart';
import '../helpers/pump_app.dart';
import '../helpers/task_factory.dart';

void main() {
  late FakeTaskRepository repository;

  setUp(() {
    repository = FakeTaskRepository([
      buildTask(id: '1', title: 'Design the onboarding'),
      buildTask(
        id: '2',
        title: 'Fix the login bug',
        status: TaskStatus.completed,
        completedAt: testNow,
      ),
    ]);
  });

  group('Tasks tab', () {
    testWidgets('shows tasks, progress and filters', (tester) async {
      await pumpPulseApp(tester, repository: repository);

      expect(find.text(AppStrings.tasksTitle), findsOneWidget);
      expect(find.text('Design the onboarding'), findsOneWidget);
      expect(find.text(AppStrings.progressSummary(1, 2)), findsOneWidget);
      expect(find.text('${AppStrings.filterAll}  2'), findsOneWidget);
    });

    testWidgets('filters by status', (tester) async {
      await pumpPulseApp(tester, repository: repository);

      final doneFilter = find.text('${AppStrings.statusCompleted}  1');
      await tester.ensureVisible(doneFilter);
      await tester.pumpAndSettle();
      await tester.tap(doneFilter);
      await tester.pumpAndSettle();

      expect(find.text('Fix the login bug'), findsOneWidget);
      expect(find.text('Design the onboarding'), findsNothing);
    });

    testWidgets('empty state offers to create a task', (tester) async {
      await pumpPulseApp(tester, repository: FakeTaskRepository());

      expect(find.text(AppStrings.emptyTasksTitle), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, AppStrings.newTask));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.createTask), findsOneWidget);
    });

    testWidgets('load errors are friendly and retryable', (tester) async {
      repository.failure = const NetworkFailure();
      await pumpPulseApp(tester, repository: repository);

      expect(find.text(AppStrings.errorNetwork), findsOneWidget);

      repository.failure = null;
      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();
      expect(find.text('Design the onboarding'), findsOneWidget);
    });

    testWidgets('the check button completes a task', (tester) async {
      await pumpPulseApp(tester, repository: repository);

      await tester.tap(find.byType(TaskCheckButton).first);
      await tester.pumpAndSettle();

      expect(repository.tasks.first.status, TaskStatus.completed);
      expect(find.text(AppStrings.taskCompleted), findsOneWidget);
    });

    testWidgets('swipe to delete asks first', (tester) async {
      await pumpPulseApp(tester, repository: repository);

      await tester.drag(
        find.widgetWithText(TaskCard, 'Design the onboarding'),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.deleteTaskTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.delete));
      await tester.pumpAndSettle();

      expect(find.text('Design the onboarding'), findsNothing);
      expect(repository.tasks.map((t) => t.id), ['2']);
    });
  });

  group('Task details', () {
    testWidgets('opens from the list and completes the task', (tester) async {
      await pumpPulseApp(tester, repository: repository);

      await tester.tap(find.text('Design the onboarding'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.taskDetailsTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.complete));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.reopen), findsOneWidget);
      expect(find.text(AppStrings.completedLabel), findsOneWidget);
    });

    testWidgets('deep link loads the task by id', (tester) async {
      final container = await pumpPulseApp(tester, repository: repository);

      container.read(appRouterProvider).go(AppRoutes.taskDetailsLocation('2'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.taskDetailsTitle), findsOneWidget);
      expect(find.text('Fix the login bug'), findsOneWidget);
    });

    testWidgets('unknown task shows an error, not a crash', (tester) async {
      final container = await pumpPulseApp(tester, repository: repository);

      container.read(appRouterProvider).go(AppRoutes.taskDetailsLocation('x'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorServer), findsOneWidget);
    });

    testWidgets('delete confirms, then returns to the list', (tester) async {
      await pumpPulseApp(tester, repository: repository);
      await tester.tap(find.text('Design the onboarding'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(AppStrings.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.delete));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.tasksTitle), findsOneWidget);
      expect(find.text(AppStrings.taskDeleted), findsOneWidget);
    });
  });

  group('Task form', () {
    Future<void> openNewTask(WidgetTester tester) async {
      await tester.tap(find.byTooltip(AppStrings.newTask));
      await tester.pumpAndSettle();
    }

    FilledButton submitButton(WidgetTester tester) =>
        tester.widget(find.widgetWithText(FilledButton, AppStrings.createTask));

    testWidgets('submit stays disabled until the title is valid', (
      tester,
    ) async {
      await pumpPulseApp(tester, repository: repository);
      await openNewTask(tester);

      expect(submitButton(tester).onPressed, isNull);
      await tester.enterText(find.byType(TextFormField).first, 'ab');
      await tester.pump();
      expect(submitButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextFormField).first, 'Plan sprint');
      await tester.pump();
      expect(submitButton(tester).onPressed, isNotNull);
    });

    testWidgets('creates a task and returns to the list', (tester) async {
      await pumpPulseApp(tester, repository: repository);
      await openNewTask(tester);

      await tester.enterText(find.byType(TextFormField).first, 'Plan sprint');
      await tester.pump();
      await tester.tap(find.text(AppStrings.priorityHigh));
      await tester.pump();
      await tester.tap(find.text(AppStrings.createTask));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.taskCreated), findsOneWidget);
      expect(find.text('Plan sprint'), findsOneWidget);
    });

    // Regression: the form used to close even when saving failed.
    testWidgets('stays open with a friendly error when saving fails', (
      tester,
    ) async {
      await pumpPulseApp(tester, repository: repository);
      await openNewTask(tester);
      repository.failure = const NetworkFailure();

      await tester.enterText(find.byType(TextFormField).first, 'Plan sprint');
      await tester.pump();
      await tester.tap(find.text(AppStrings.createTask));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.createTask), findsOneWidget);
      expect(find.text(AppStrings.errorNetwork), findsOneWidget);
    });

    testWidgets('edits an existing task', (tester) async {
      await pumpPulseApp(tester, repository: repository);
      await tester.tap(find.text('Design the onboarding'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.edit));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'Design the new onboarding',
      );
      await tester.pump();
      await tester.tap(find.text(AppStrings.statusInProgress).last);
      await tester.pump();
      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();

      expect(repository.tasks.first.title, 'Design the new onboarding');
      expect(repository.tasks.first.status, TaskStatus.inProgress);
      expect(find.text(AppStrings.taskUpdated), findsOneWidget);
    });
  });

  group('Settings', () {
    testWidgets('switches and remembers the theme', (tester) async {
      await pumpPulseApp(tester, repository: repository);

      await tester.tap(find.text(AppStrings.navSettings));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(AppearanceMode.dark.label));
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('appearance_mode'), 'dark');
    });

    testWidgets('unbuilt rows say "coming soon"', (tester) async {
      await pumpPulseApp(tester, repository: repository);
      await tester.tap(find.text(AppStrings.navSettings));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.languageTitle));
      await tester.pump();
      expect(find.text(AppStrings.comingSoon), findsOneWidget);
    });

    testWidgets('restores the saved theme on launch', (tester) async {
      await pumpPulseApp(
        tester,
        repository: repository,
        preferences: {'appearance_mode': 'dark'},
      );
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
    });
  });

  group('Responsive', () {
    for (final mode in ['light', 'dark']) {
      testWidgets('main screens fit a 360dp phone ($mode)', (tester) async {
        await pumpPulseApp(
          tester,
          repository: repository,
          size: const Size(360, 740),
          preferences: {'appearance_mode': mode},
        );
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Design the onboarding'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.navSettings));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('tablet landscape lays out without overflow', (tester) async {
      await pumpPulseApp(
        tester,
        repository: repository,
        size: const Size(1180, 820),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Design the onboarding'), findsOneWidget);
    });
  });
}
