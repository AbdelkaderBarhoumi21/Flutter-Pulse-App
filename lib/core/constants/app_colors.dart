import 'package:flutter/painting.dart';

/// Raw brand palette. Widgets never read these directly — they go through
/// `context.colorScheme` / `context.colors` so light and dark stay in sync.
abstract final class AppColors {
  // Brand
  static const Color indigo = Color(0xFF5B5BF6);
  static const Color indigoLight = Color(0xFF8B8CFF);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color indigoDeep = Color(0xFF6366F1);
  static const Color teal = Color(0xFF0EA5A4);
  static const Color tealLight = Color(0xFF2DD4BF);

  // Semantic
  static const Color green = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFF4ADE80);
  static const Color amber = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFBBF24);
  static const Color rose = Color(0xFFE11D48);
  static const Color roseLight = Color(0xFFFB7185);
  static const Color sky = Color(0xFF0284C7);
  static const Color skyLight = Color(0xFF38BDF8);

  // Light neutrals
  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFEEF0F7);
  static const Color lightBorder = Color(0xFFE3E6EF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  // Dark neutrals
  static const Color darkBackground = Color(0xFF0B0D14);
  static const Color darkSurface = Color(0xFF141824);
  static const Color darkSurfaceMuted = Color(0xFF1C2132);
  static const Color darkBorder = Color(0xFF262C3F);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
