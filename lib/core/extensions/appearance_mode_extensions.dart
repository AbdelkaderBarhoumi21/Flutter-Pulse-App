import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/features/settings/domain/entities/appearance_mode.dart';

extension AppearanceModeX on AppearanceMode {
  String get label => switch (this) {
    AppearanceMode.system => AppStrings.themeSystem,
    AppearanceMode.light => AppStrings.themeLight,
    AppearanceMode.dark => AppStrings.themeDark,
  };

  IconData get icon => switch (this) {
    AppearanceMode.system => Icons.brightness_auto_rounded,
    AppearanceMode.light => Icons.light_mode_rounded,
    AppearanceMode.dark => Icons.dark_mode_rounded,
  };

  ThemeMode get themeMode => switch (this) {
    AppearanceMode.system => ThemeMode.system,
    AppearanceMode.light => ThemeMode.light,
    AppearanceMode.dark => ThemeMode.dark,
  };
}
