import 'package:flutter_pulse_app/core/constants/app_limits.dart';

/// Every user-facing string in one place (ready to move to l10n later).
abstract final class AppStrings {
  // ── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'Pulse';

  // ── Common ───────────────────────────────────────────────────────────────
  static const String retry = 'Try again';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String save = 'Save changes';
  static const String comingSoon = 'Coming soon — we are working on it!';
  static const String notAvailable = '—';

  // ── Errors (never show raw exceptions) ───────────────────────────────────
  static const String errorTitle = 'Something went wrong';
  static const String errorNetwork =
      'You seem to be offline. Check your connection and try again.';
  static const String errorServer =
      'Our server had a hiccup. Please try again in a moment.';
  static const String errorUnexpected =
      'An unexpected error occurred. Please try again.';
  static const String errorNotFoundTitle = 'Page not found';
  static const String errorNotFoundMessage =
      'The page you are looking for does not exist.';
  static const String goHome = 'Back to tasks';

  // ── Navigation ───────────────────────────────────────────────────────────
  static const String navTasks = 'Tasks';
  static const String navSettings = 'Settings';

  // ── Tasks: list ──────────────────────────────────────────────────────────
  static const String tasksTitle = 'My tasks';
  static const String newTask = 'New task';
  static const String progressTitle = 'Your progress';
  static String progressSummary(int done, int total) =>
      '$done of $total ${total == 1 ? 'task' : 'tasks'} completed';
  static const String progressAllDone = 'All caught up — great work!';
  static const String progressEmpty = 'Add a task to start tracking.';
  static const String emptyTasksTitle = 'No tasks yet';
  static const String emptyTasksMessage =
      'Create your first task and it will show up here.';
  static const String emptyFilterTitle = 'Nothing here';
  static const String emptyFilterMessage =
      'No tasks match this filter right now.';
  static const String taskDeleted = 'Task deleted';
  static const String taskCompleted = 'Task completed';
  static const String taskReopened = 'Task moved back to to-do';
  static const String markComplete = 'Mark as complete';
  static const String markIncomplete = 'Mark as not complete';

  // ── Tasks: filters ───────────────────────────────────────────────────────
  static const String filterAll = 'All';

  // ── Tasks: status & priority ─────────────────────────────────────────────
  static const String statusPending = 'To do';
  static const String statusInProgress = 'In progress';
  static const String statusCompleted = 'Done';
  static const String priorityLow = 'Low';
  static const String priorityMedium = 'Medium';
  static const String priorityHigh = 'High';

  // ── Tasks: details ───────────────────────────────────────────────────────
  static const String taskDetailsTitle = 'Task details';
  static const String noDescription = 'No description added.';
  static const String descriptionLabel = 'Description';
  static const String createdLabel = 'Created';
  static const String completedLabel = 'Completed';
  static const String statusLabel = 'Status';
  static const String priorityLabel = 'Priority';
  static const String edit = 'Edit';
  static const String complete = 'Complete';
  static const String reopen = 'Reopen';
  static const String deleteTaskTitle = 'Delete this task?';
  static const String deleteTaskMessage =
      'This permanently removes the task. You can’t undo this.';

  // ── Tasks: form ──────────────────────────────────────────────────────────
  static const String editTaskTitle = 'Edit task';
  static const String titleLabel = 'Title';
  static const String titleHint = 'What needs to be done?';
  static const String descriptionHint = 'Add some details (optional)';
  static const String createTask = 'Create task';
  static const String taskCreated = 'Task created';
  static const String taskUpdated = 'Changes saved';

  // ── Validation ───────────────────────────────────────────────────────────
  static const String titleRequired = 'Title is required';
  static const String titleTooShort =
      'Title must be at least ${AppLimits.minTitleLength} characters';
  static const String titleTooLong =
      'Title must not exceed ${AppLimits.maxTitleLength} characters';
  static const String descriptionTooLong =
      'Description must not exceed ${AppLimits.maxDescriptionLength} characters';
  static const String taskIdRequired = 'Task ID cannot be empty';
  static const String deviceTokenRequired = 'Device token cannot be empty';

  // ── Dates ────────────────────────────────────────────────────────────────
  static const String justNow = 'Just now';
  static String minutesAgo(int m) => '$m min ago';
  static String hoursAgo(int h) => '$h h ago';
  static const String yesterday = 'Yesterday';
  static String daysAgo(int d) => '$d days ago';

  // ── Settings ─────────────────────────────────────────────────────────────
  static const String settingsTitle = 'Settings';
  static const String sectionAppearance = 'Appearance';
  static const String sectionPreferences = 'Preferences';
  static const String sectionAbout = 'About';
  static const String themeTitle = 'Theme';
  static const String themeSystem = 'System default';
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';
  static const String notificationsTitle = 'Notifications';
  static const String notificationsSubtitle = 'Task updates in real time';
  static const String languageTitle = 'Language';
  static const String languageSubtitle = 'English';
  static const String versionTitle = 'Version';
  static const String serverTitle = 'Server';
  static const String privacyTitle = 'Privacy policy';
  static const String privacySubtitle = 'How we handle your data';
  static const String rateTitle = 'Rate Pulse';
  static const String rateSubtitle = 'Tell us what you think';

  // ── Notifications ────────────────────────────────────────────────────────
  static const String notificationFallbackTitle = 'Task update';
  static const String notificationChannelName = 'Task Updates';
  static const String notificationChannelDescription =
      'Notifications about task changes';
}
