import 'package:flutter/widgets.dart';
import 'package:flutter_pulse_app/core/routing/app_routes.dart';
import 'package:flutter_pulse_app/core/routing/route_not_found_page.dart';
import 'package:flutter_pulse_app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_pulse_app/features/shell/presentation/pages/app_shell_page.dart';
import 'package:flutter_pulse_app/features/shell/presentation/widgets/fade_indexed_stack.dart';
import 'package:flutter_pulse_app/features/task/presentation/pages/task_details_page.dart';
import 'package:flutter_pulse_app/features/task/presentation/pages/task_form_page.dart';
import 'package:flutter_pulse_app/features/task/presentation/pages/task_list_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// The app's route table:
///
/// ```text
/// /tasks                 Tasks tab
/// /tasks/new             new task          (full screen)
/// /tasks/:id             task details      (full screen)
/// /tasks/:id/edit        edit task         (full screen)
/// /settings              Settings tab
/// ```
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.tasksPath,
    errorBuilder: (_, _) => const RouteNotFoundPage(),
    routes: [
      StatefulShellRoute(
        builder: (_, _, shell) => AppShellPage(navigationShell: shell),
        navigatorContainerBuilder: (_, shell, children) =>
            FadeIndexedStack(index: shell.currentIndex, children: children),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.tasksName,
                path: AppRoutes.tasksPath,
                builder: (_, _) => const TaskListPage(),
                routes: [
                  // Declared before `:id` so "new" isn't read as an id.
                  GoRoute(
                    name: AppRoutes.newTaskName,
                    path: AppRoutes.newTaskPath,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const TaskFormPage(),
                  ),
                  GoRoute(
                    name: AppRoutes.taskDetailsName,
                    path: AppRoutes.taskDetailsPath,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, state) => TaskDetailsPage(
                      taskId: state.pathParameters[AppRoutes.taskIdParam]!,
                    ),
                    routes: [
                      GoRoute(
                        name: AppRoutes.editTaskName,
                        path: AppRoutes.editTaskPath,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (_, state) => TaskFormPage(
                          taskId: state.pathParameters[AppRoutes.taskIdParam],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.settingsName,
                path: AppRoutes.settingsPath,
                builder: (_, _) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
