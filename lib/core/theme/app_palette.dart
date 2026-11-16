import 'package:easybook_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Brand values that `ColorScheme` has no slot for (gradients, muted text,
/// card shadow). Read it with `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const new({
    required this.brandGradient,
    required this.imageScrim,
    required this.accent,
    required this.textSecondary,
    required this.surfaceMuted,
    required this.cardShadow,
  });

  static const AppPalette light = AppPalette(
    brandGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.brandIndigo, AppColors.brandViolet],
    ),
    imageScrim: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.transparent, AppColors.scrim],
    ),
    accent: AppColors.accentCoral,
    textSecondary: AppColors.lightTextSecondary,
    surfaceMuted: AppColors.lightSurfaceMuted,
    cardShadow: AppColors.shadow,
  );

  static const AppPalette dark = AppPalette(
    brandGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.brandIndigo, AppColors.brandViolet],
    ),
    imageScrim: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.transparent, AppColors.scrim],
    ),
    accent: AppColors.accentCoralLight,
    textSecondary: AppColors.darkTextSecondary,
    surfaceMuted: AppColors.darkSurfaceMuted,
    cardShadow: AppColors.shadowDark,
  );

  /// Indigo -> violet, used for hero areas and the primary button.
  final LinearGradient brandGradient;

  /// Transparent -> dark, laid over photos so white text stays readable.
  final LinearGradient imageScrim;

  /// Coral highlight (prices, badges).
  final Color accent;
  final Color textSecondary;
  final Color surfaceMuted;
  final Color cardShadow;

  @override
  AppPalette copyWith({
    LinearGradient? brandGradient,
    LinearGradient? imageScrim,
    Color? accent,
    Color? textSecondary,
    Color? surfaceMuted,
    Color? cardShadow,
  }) {
    return AppPalette(
      brandGradient: brandGradient ?? this.brandGradient,
      imageScrim: imageScrim ?? this.imageScrim,
      accent: accent ?? this.accent,
      textSecondary: textSecondary ?? this.textSecondary,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      brandGradient: LinearGradient.lerp(
        brandGradient,
        other.brandGradient,
        t,
      )!,
      imageScrim: LinearGradient.lerp(imageScrim, other.imageScrim, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}
