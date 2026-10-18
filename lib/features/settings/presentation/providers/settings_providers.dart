import 'package:flutter_pulse_app/core/config/app_env.dart';
import 'package:flutter_pulse_app/core/storage/shared_preferences_provider.dart';
import 'package:flutter_pulse_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flutter_pulse_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(sharedPreferencesProvider)),
);

/// e.g. "1.0.0 (1)"
final appVersionProvider = FutureProvider.autoDispose<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

/// Host the app talks to, shown in About.
final apiHostProvider = Provider<String>(
  (ref) => Uri.parse(AppEnv.apiBaseUrl).authority,
);
