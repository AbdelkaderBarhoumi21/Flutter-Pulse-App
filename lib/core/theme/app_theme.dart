import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pulse_app/core/constants/app_colors.dart';
import 'package:flutter_pulse_app/core/constants/app_layout.dart';
import 'package:flutter_pulse_app/core/constants/app_radius.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/theme/app_semantic_colors.dart';
import 'package:flutter_pulse_app/core/theme/app_typography.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Material 3 light and dark themes, both built from the same recipe so the
/// two modes can never drift apart.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppSemanticColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppSemanticColors.dark);

  /// Status / navigation bar style with icons that stay visible on the
  /// plain background of the given brightness.
  static SystemUiOverlayStyle overlayStyleFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = isDark ? AppSemanticColors.dark : AppSemanticColors.light;
    return (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
        .copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: colors.surface,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        );
  }

  /// Shimmer skeleton look, provided app-wide through `SkeletonizerConfig`.
  static SkeletonizerConfigData skeletonFor(AppSemanticColors c) {
    return SkeletonizerConfigData(
      effectResolver: (_) =>
          ShimmerEffect(baseColor: c.surfaceMuted, highlightColor: c.surface),
      textBorderRadius: TextBoneBorderRadius(
        BorderRadius.circular(AppRadius.xs.r),
      ),
    );
  }

  static ThemeData _build(Brightness brightness, AppSemanticColors c) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? AppColors.indigoLight : AppColors.indigo;
    final onPrimary = isDark ? AppColors.darkBackground : AppColors.white;

    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.indigo,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: primary.withValues(alpha: 0.14),
          onPrimaryContainer: primary,
          secondary: isDark ? AppColors.tealLight : AppColors.teal,
          error: c.danger,
          onError: AppColors.white,
          surface: c.surface,
          onSurface: c.textPrimary,
          onSurfaceVariant: c.textSecondary,
          surfaceContainerLowest: c.surface,
          surfaceContainerLow: c.surface,
          surfaceContainer: c.surfaceMuted,
          surfaceContainerHigh: c.surfaceMuted,
          surfaceContainerHighest: c.surfaceMuted,
          outline: c.border,
          outlineVariant: c.border,
          shadow: c.shadow,
        );

    final textTheme = AppTypography.textTheme(
      primary: c.textPrimary,
      secondary: c.textSecondary,
    );

    final mdRadius = BorderRadius.circular(AppRadius.md.r);
    final lgRadius = BorderRadius.circular(AppRadius.lg.r);
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: AppSpacing.lg.w,
      vertical: AppSpacing.sm.h + 2,
    );
    final buttonShape = RoundedRectangleBorder(borderRadius: mdRadius);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: mdRadius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.border,
      splashFactory: InkSparkle.splashFactory,
      extensions: [c],
      appBarTheme: AppBarThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: overlayStyleFor(brightness),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: lgRadius,
          side: BorderSide(color: c.border),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: c.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.md.h,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: c.textTertiary),
        labelStyle: textTheme.bodyMedium,
        floatingLabelStyle: textTheme.labelLarge?.copyWith(color: primary),
        border: inputBorder(c.border),
        enabledBorder: inputBorder(c.border),
        focusedBorder: inputBorder(primary, 1.6),
        errorBorder: inputBorder(c.danger),
        focusedErrorBorder: inputBorder(c.danger, 1.6),
        errorStyle: textTheme.bodySmall?.copyWith(color: c.danger),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          disabledBackgroundColor: c.surfaceMuted,
          disabledForegroundColor: c.textTertiary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.border),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 2,
        highlightElevation: 4,
        extendedTextStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: lgRadius),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withValues(alpha: 0.14),
        elevation: 0,
        height: AppLayout.navigationBarHeight.h,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? primary
                : c.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primary
                : c.textSecondary,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: primary.withValues(alpha: 0.14),
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        labelStyle: textTheme.labelLarge,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
        showCheckmark: false,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: c.surface,
          foregroundColor: c.textSecondary,
          selectedBackgroundColor: primary.withValues(alpha: 0.14),
          selectedForegroundColor: primary,
          side: BorderSide(color: c.border),
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? c.surfaceMuted : c.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? c.textPrimary : c.surface,
        ),
        shape: RoundedRectangleBorder(borderRadius: mdRadius),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl.r),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl.r),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primary,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
        shape: RoundedRectangleBorder(borderRadius: mdRadius),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: c.surfaceMuted,
        circularTrackColor: c.surfaceMuted,
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? c.surfaceMuted : c.textPrimary,
          borderRadius: BorderRadius.circular(AppRadius.sm.r),
        ),
        textStyle: textTheme.labelMedium?.copyWith(
          color: isDark ? c.textPrimary : c.surface,
        ),
      ),
    );
  }
}
