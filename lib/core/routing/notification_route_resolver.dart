import 'package:flutter_pulse_app/core/extensions/string_extensions.dart';
import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';
import 'package:flutter_pulse_app/core/routing/app_routes.dart';

/// Turns a notification payload into an in-app location.
///
/// The backend contract uses `route: "/task-details"`; the legacy app path
/// `/taskDetails` is accepted too. Anything unknown falls back to the task
/// list instead of GoRouter's error page.
abstract final class NotificationRouteResolver {
  static const Set<String> _taskDetailsRoutes = {
    '/task-details',
    '/taskDetails',
  };

  static const Set<String> _topLevelRoutes = {
    AppRoutes.tasksPath,
    AppRoutes.settingsPath,
  };

  static String resolve(NotificationPayload payload) {
    final route = payload.route?.trim();
    final taskId = payload.taskId?.trim();

    if (_taskDetailsRoutes.contains(route) && !taskId.isNullOrBlank) {
      return AppRoutes.taskDetailsLocation(taskId!);
    }
    if (_topLevelRoutes.contains(route)) return route!;
    return AppRoutes.tasksPath;
  }
}
