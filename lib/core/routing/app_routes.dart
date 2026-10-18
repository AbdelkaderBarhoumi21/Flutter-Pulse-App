/// Route names and paths in one place. Navigate by name (see
/// `AppNavigationX`) and build locations with the helpers below.
abstract final class AppRoutes {
  static const String taskIdParam = 'id';

  // ── Tasks tab ────────────────────────────────────────────────────────────
  static const String tasksName = 'tasks';
  static const String tasksPath = '/tasks';

  static const String newTaskName = 'newTask';
  static const String newTaskPath = 'new';

  static const String taskDetailsName = 'taskDetails';
  static const String taskDetailsPath = ':$taskIdParam';

  static const String editTaskName = 'editTask';
  static const String editTaskPath = 'edit';

  // ── Settings tab ─────────────────────────────────────────────────────────
  static const String settingsName = 'settings';
  static const String settingsPath = '/settings';

  static String taskDetailsLocation(String id) =>
      '$tasksPath/${Uri.encodeComponent(id)}';
}
