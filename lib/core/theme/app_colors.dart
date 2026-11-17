import 'package:flutter/material.dart';

/// Every raw color in the app. Widgets never use these directly; they read
/// `Theme.of(context).colorScheme` or the `AppPalette` theme extension.
///
/// The look is bold and high-contrast: near-black "ink" hero areas with a
/// slowly moving aurora glow, electric lime for calls to action, and clean
/// warm-white content surfaces.
abstract final class AppColors {
  // Ink: hero areas, navigation bar, dark accents (same in both themes).
  static const Color ink = Color(0xFF0D0F14);
  static const Color inkRaised = Color(0xFF1A1D25);
  static const Color inkLine = Color(0xFF2A2E38);

  // Lime: the signature accent. Fills only (with ink text on top).
  static const Color lime = Color(0xFFC6F24E);
  static const Color limeDeep = Color(0xFF3F6212);
  static const Color limeSoftLight = Color(0xFFEEF8D3);
  static const Color limeSoftDark = Color(0xFF222C10);

  // Aurora glow colors (behind hero areas).
  static const Color auroraLime = Color(0xFFB4F03A);
  static const Color auroraTeal = Color(0xFF14B8A6);
  static const Color auroraSky = Color(0xFF38BDF8);

  // Light theme surfaces and text.
  static const Color lightBackground = Color(0xFFF4F5F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFECEEE6);
  static const Color lightOutline = Color(0xFFE2E4DC);
  static const Color lightTextPrimary = Color(0xFF0D0F14);
  static const Color lightTextSecondary = Color(0xFF5C616C);

  // Dark theme surfaces and text.
  static const Color darkBackground = Color(0xFF07080B);
  static const Color darkSurface = Color(0xFF12141A);
  static const Color darkSurfaceMuted = Color(0xFF1C1F27);
  static const Color darkOutline = Color(0xFF272B34);
  static const Color darkTextPrimary = Color(0xFFF2F3EE);
  static const Color darkTextSecondary = Color(0xFF9CA2AC);

  // Feedback.
  static const Color error = Color(0xFFD92D20);
  static const Color errorLight = Color(0xFFFF7A70);

  // Status tones (always shown together with a text label).
  static const Color amber = Color(0xFFB45309);
  static const Color amberLight = Color(0xFFFBBF24);
  static const Color blue = Color(0xFF1D4ED8);
  static const Color blueLight = Color(0xFF8AB4F8);
  static const Color green = Color(0xFF15803D);
  static const Color greenLight = Color(0xFF4ADE80);
  static const Color slate = Color(0xFF64748B);
  static const Color slateLight = Color(0xFF94A3B8);

  // Fixed colors.
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteMuted = Color(0xB3FFFFFF);
  static const Color whiteFaint = Color(0x1FFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color scrim = Color(0xD90D0F14);
  static const Color shadow = Color(0x140D0F14);
  static const Color shadowDark = Color(0x66000000);
  static const Color limeGlow = Color(0x66C6F24E);
}
