import 'package:flutter/foundation.dart';

/// Compile-time environment values.
///
/// Values come from `--dart-define-from-file=.env` (see `.env.example`), so
/// nothing environment-specific is hard-coded in source. The defaults keep
/// `flutter run` working out of the box against a local backend.
abstract final class AppEnv {
  /// Base URL of the task_api backend. `10.0.2.2` is the host machine as
  /// seen from the Android emulator.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  /// Whether HTTP traffic is logged. Never enabled in release builds.
  static const bool enableHttpLogs =
      !kReleaseMode && bool.fromEnvironment('ENABLE_HTTP_LOGS');
}
