import 'package:flutter/widgets.dart';
import 'package:flutter_pulse_app/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';

/// Type-safe navigation helpers, so widgets never spell out route strings.
extension AppNavigationX on BuildContext {
  Future<void> pushNewTask() => pushNamed<void>(AppRoutes.newTaskName);

  Future<void> pushTaskDetails(String id) => pushNamed<void>(
    AppRoutes.taskDetailsName,
    pathParameters: {AppRoutes.taskIdParam: id},
  );

  Future<void> pushEditTask(String id) => pushNamed<void>(
    AppRoutes.editTaskName,
    pathParameters: {AppRoutes.taskIdParam: id},
  );

  void goToTasks() => goNamed(AppRoutes.tasksName);
}
