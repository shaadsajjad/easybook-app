import 'package:flutter/material.dart';

/// Every raw color in the app. Widgets never use these directly; they read
/// `Theme.of(context).colorScheme` or the `AppPalette` theme extension.
abstract final class AppColors {
  // Brand.
  static const Color brandIndigo = Color(0xFF4F46E5);
  static const Color brandViolet = Color(0xFF7C3AED);
  static const Color brandIndigoLight = Color(0xFF8C86FF);
  static const Color brandVioletLight = Color(0xFFA78BFA);
  static const Color accentCoral = Color(0xFFFF6B5A);
  static const Color accentCoralLight = Color(0xFFFF8A7A);

  // Light theme surfaces and text.
  static const Color lightBackground = Color(0xFFF6F6FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFEFEFF6);
  static const Color lightOutline = Color(0xFFE3E3EE);
  static const Color lightTextPrimary = Color(0xFF14142B);
  static const Color lightTextSecondary = Color(0xFF6B6B85);

  // Dark theme surfaces and text.
  static const Color darkBackground = Color(0xFF0E0F1D);
  static const Color darkSurface = Color(0xFF191A2D);
  static const Color darkSurfaceMuted = Color(0xFF23243A);
  static const Color darkOutline = Color(0xFF30314A);
  static const Color darkTextPrimary = Color(0xFFF3F3F9);
  static const Color darkTextSecondary = Color(0xFFA5A5BF);

  // Feedback.
  static const Color error = Color(0xFFE5484D);
  static const Color errorLight = Color(0xFFFF7A7E);

  // Status tones (always shown together with a text label).
  static const Color amber = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFBBF24);
  static const Color green = Color(0xFF059669);
  static const Color greenLight = Color(0xFF34D399);
  static const Color slate = Color(0xFF64748B);
  static const Color slateLight = Color(0xFF94A3B8);

  // Fixed colors.
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color scrim = Color(0xCC0B0B1A);
  static const Color shadow = Color(0x1A1B1A4D);
  static const Color shadowDark = Color(0x66000000);
}
