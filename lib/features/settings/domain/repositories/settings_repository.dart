import 'package:flutter_pulse_app/features/settings/domain/entities/appearance_mode.dart';

abstract interface class SettingsRepository {
  /// The saved preference, or [AppearanceMode.system] if none.
  AppearanceMode loadAppearanceMode();

  Future<void> saveAppearanceMode(AppearanceMode mode);
}
