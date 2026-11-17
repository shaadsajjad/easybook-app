import 'package:flutter/material.dart';

/// The type scale. Big, heavy headlines (w800) for a bold editorial look;
/// body text stays relaxed. No negative letter spacing: it makes Bengali
/// letters overlap. The platform font is used (Roboto / San Francisco), which also
/// renders Bengali correctly.
abstract final class AppTextStyles {
  static TextTheme textTheme({
    required TextTheme base,
    required Color primary,
    required Color secondary,
  }) {
    final theme = base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 38,
        height: 1.1,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 30,
        height: 1.15,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 24,
        height: 1.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
      bodySmall: base.bodySmall?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
    return theme
        .apply(bodyColor: primary, displayColor: primary)
        .copyWith(
          bodySmall: theme.bodySmall?.copyWith(color: secondary),
          labelSmall: theme.labelSmall?.copyWith(color: secondary),
        );
  }
}
