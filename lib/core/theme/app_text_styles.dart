import 'package:flutter/material.dart';

/// The type scale. Headlines are heavy; body text is relaxed.
/// No negative letter spacing: it makes Bengali letters overlap. The platform font is used (Roboto / San Francisco),
/// which also renders Bengali correctly.
abstract final class AppTextStyles {
  static TextTheme textTheme({
    required TextTheme base,
    required Color primary,
    required Color secondary,
  }) {
    final theme = base.copyWith(
      displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.w800),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
      bodySmall: base.bodySmall?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w600),
    );
    return theme
        .apply(bodyColor: primary, displayColor: primary)
        .copyWith(
          bodySmall: theme.bodySmall?.copyWith(color: secondary),
          labelSmall: theme.labelSmall?.copyWith(color: secondary),
        );
  }
}
