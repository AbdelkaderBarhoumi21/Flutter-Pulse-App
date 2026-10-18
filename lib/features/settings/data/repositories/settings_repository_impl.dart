import 'package:flutter_pulse_app/features/settings/domain/entities/appearance_mode.dart';
import 'package:flutter_pulse_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._preferences);
  final SharedPreferences _preferences;

  static const String _appearanceModeKey = 'appearance_mode';

  @override
  AppearanceMode loadAppearanceMode() {
    final stored = _preferences.getString(_appearanceModeKey);
    return AppearanceMode.values
            .where((mode) => mode.name == stored)
            .firstOrNull ??
        AppearanceMode.system;
  }

  @override
  Future<void> saveAppearanceMode(AppearanceMode mode) =>
      _preferences.setString(_appearanceModeKey, mode.name);
}
