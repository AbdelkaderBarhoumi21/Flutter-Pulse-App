import 'package:flutter_pulse_app/core/storage/shared_preferences_provider.dart';
import 'package:flutter_pulse_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flutter_pulse_app/features/settings/domain/entities/appearance_mode.dart';
import 'package:flutter_pulse_app/features/settings/presentation/providers/appearance_mode_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SharedPreferences> prefsWith(Map<String, Object> values) {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('SettingsRepositoryImpl', () {
    test('defaults to system and ignores unknown values', () async {
      expect(
        SettingsRepositoryImpl(await prefsWith({})).loadAppearanceMode(),
        AppearanceMode.system,
      );
      expect(
        SettingsRepositoryImpl(
          await prefsWith({'appearance_mode': 'sepia'}),
        ).loadAppearanceMode(),
        AppearanceMode.system,
      );
    });

    test('saves and loads', () async {
      final repository = SettingsRepositoryImpl(await prefsWith({}));
      await repository.saveAppearanceMode(AppearanceMode.dark);
      expect(repository.loadAppearanceMode(), AppearanceMode.dark);
    });
  });

  test('AppearanceModeController persists the selection', () async {
    final prefs = await prefsWith({'appearance_mode': 'light'});
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(appearanceModeControllerProvider),
      AppearanceMode.light,
    );

    await container
        .read(appearanceModeControllerProvider.notifier)
        .select(AppearanceMode.dark);

    expect(
      container.read(appearanceModeControllerProvider),
      AppearanceMode.dark,
    );
    expect(prefs.getString('appearance_mode'), 'dark');
  });
}
