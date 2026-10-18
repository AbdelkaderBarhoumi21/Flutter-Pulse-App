import 'package:flutter/painting.dart';
import 'package:flutter_pulse_app/core/constants/app_colors.dart';

abstract final class AppGradients {
  /// Hero gradient used on highlight cards (e.g. the progress summary).
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.indigoDeep, AppColors.violet],
  );
}
