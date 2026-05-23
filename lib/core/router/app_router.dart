import 'package:flutter_pulse_app/core/di/notifications_services_provider.dart';
import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';
import 'package:flutter_pulse_app/core/router/app_routes_names.dart';
import 'package:flutter_pulse_app/core/router/app_routes_path.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/presentation/views/screen/task_details_screen.dart';
import 'package:flutter_pulse_app/features/task/presentation/views/screen/task_form_screen.dart';
import 'package:flutter_pulse_app/features/task/presentation/views/screen/task_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutesPath.tasksList,
    routes: [
      GoRoute(
        name: AppRoutesNames.tasksList,
        path: AppRoutesPath.tasksList,
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: AppRoutesPath.taskDetails,
        name: AppRoutesNames.taskDetails,
        builder: (context, state) {
          final taskId = state.uri.queryParameters['id']!;
          return TaskDetailsScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: AppRoutesPath.taskForm,
        name: AppRoutesNames.taskForm,
        builder: (context, state) {
          final existing = state.extra as TaskEntity?;
          return TaskFormScreen(existing: existing);
        },
      ),
    ],
  );
  // Backend sends `data: { route: "/task-details", taskId: "uuid", ... }`.
  // Flutter receives it via `onMessageOpenedApp` (or `getInitialMessage` if cold-started).

  ref
      .read(fcmServiceProvider)
      .bootstrap(
        onTap: (NotificationPayload p) {
          final route = p.route;
          final id = p.taskId;
          if (route == null) return;
          if (id != null) {
            // `?` = query params
            // path: '/tasks/:id'
            router.go('$route?id=$id');
          } else {
            router.go(route);
          }
        },
      );

  return router;
});
