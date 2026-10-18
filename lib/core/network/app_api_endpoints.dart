/// REST paths, relative to `AppEnv.apiBaseUrl` (set as Dio's `baseUrl`).
abstract final class AppApiEndpoints {
  static const String tasks = '/tasks';
  static String task(String id) => '/tasks/${Uri.encodeComponent(id)}';

  static const String devices = '/devices';
}
