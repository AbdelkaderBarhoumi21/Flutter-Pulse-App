import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';
import 'package:flutter_pulse_app/core/routing/app_routes.dart';
import 'package:flutter_pulse_app/core/routing/notification_route_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String resolve({String? route, String? taskId}) =>
      NotificationRouteResolver.resolve(
        NotificationPayload(route: route, taskId: taskId),
      );

  // Regression: the backend sends "/task-details" while the app only knew
  // "/taskDetails", so tapping a push opened GoRouter's error page.
  test('backend route "/task-details" opens the task', () {
    expect(resolve(route: '/task-details', taskId: 'abc'), '/tasks/abc');
  });

  test('legacy app route "/taskDetails" still works', () {
    expect(resolve(route: '/taskDetails', taskId: 'abc'), '/tasks/abc');
  });

  test('task ids are URL-encoded', () {
    expect(resolve(route: '/task-details', taskId: 'a/b'), '/tasks/a%2Fb');
  });

  test('details without an id fall back to the list', () {
    expect(resolve(route: '/task-details'), AppRoutes.tasksPath);
    expect(resolve(route: '/task-details', taskId: '  '), AppRoutes.tasksPath);
  });

  test('known top-level routes are kept, unknown ones fall back', () {
    expect(resolve(route: '/settings'), AppRoutes.settingsPath);
    expect(resolve(route: '/does-not-exist'), AppRoutes.tasksPath);
    expect(resolve(), AppRoutes.tasksPath);
  });
}
