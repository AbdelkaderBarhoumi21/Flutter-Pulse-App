import 'package:flutter_pulse_app/features/settings/domain/entities/appearance_mode.dart';
import 'package:flutter_pulse_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appearanceModeControllerProvider =
    NotifierProvider<AppearanceModeController, AppearanceMode>(
      AppearanceModeController.new,
    );

/// App-wide theme preference; read by the root widget, changed in Settings.
class AppearanceModeController extends Notifier<AppearanceMode> {
  @override
  AppearanceMode build() =>
      ref.watch(settingsRepositoryProvider).loadAppearanceMode();

  Future<void> select(AppearanceMode mode) async {
    if (mode == state) return;
    state = mode;
    await ref.read(settingsRepositoryProvider).saveAppearanceMode(mode);
  }
}
