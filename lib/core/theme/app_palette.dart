import 'package:easybook_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Brand values that `ColorScheme` has no slot for: the ink hero areas, the
/// lime accent fill, the aurora glow, muted text and shadows.
/// Read it with `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const new({
    required this.imageScrim,
    required this.accent,
    required this.textSecondary,
    required this.surfaceMuted,
    required this.brandSoft,
    required this.cardShadow,
    required this.solidFill,
    required this.onSolidFill,
    required this.hero,
    required this.heroRaised,
    required this.onHero,
    required this.onHeroMuted,
    required this.glow,
    required this.aurora,
  });

  static const AppPalette light = AppPalette(
    imageScrim: _scrim,
    accent: AppColors.lime,
    textSecondary: AppColors.lightTextSecondary,
    surfaceMuted: AppColors.lightSurfaceMuted,
    brandSoft: AppColors.limeSoftLight,
    cardShadow: AppColors.shadow,
    solidFill: AppColors.lime,
    onSolidFill: AppColors.ink,
    hero: AppColors.ink,
    heroRaised: AppColors.inkRaised,
    onHero: AppColors.white,
    onHeroMuted: AppColors.whiteMuted,
    glow: AppColors.limeGlow,
    aurora: _aurora,
  );

  static const AppPalette dark = AppPalette(
    imageScrim: _scrim,
    accent: AppColors.lime,
    textSecondary: AppColors.darkTextSecondary,
    surfaceMuted: AppColors.darkSurfaceMuted,
    brandSoft: AppColors.limeSoftDark,
    cardShadow: AppColors.shadowDark,
    solidFill: AppColors.lime,
    onSolidFill: AppColors.ink,
    hero: AppColors.ink,
    heroRaised: AppColors.inkRaised,
    onHero: AppColors.white,
    onHeroMuted: AppColors.whiteMuted,
    glow: AppColors.limeGlow,
    aurora: _aurora,
  );

  static const LinearGradient _scrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.3, 1],
    colors: [AppColors.transparent, AppColors.scrim],
  );

  static const List<Color> _aurora = [
    AppColors.auroraLime,
    AppColors.auroraTeal,
    AppColors.auroraSky,
  ];

  /// Transparent -> ink, laid over photos so white text stays readable.
  final LinearGradient imageScrim;

  /// Electric lime: badges, highlights, the active nav item.
  final Color accent;
  final Color textSecondary;
  final Color surfaceMuted;

  /// A light tint of lime, behind lime-related content on light surfaces.
  final Color brandSoft;
  final Color cardShadow;

  /// Fill of primary controls (buttons, selected chips and slots).
  final Color solidFill;

  /// Text and icons on [solidFill].
  final Color onSolidFill;

  /// Background of hero areas (splash, headers, nav bar, user bubbles).
  final Color hero;

  /// Slightly lighter than [hero], for controls placed on it.
  final Color heroRaised;
  final Color onHero;
  final Color onHeroMuted;

  /// Soft lime light used for glows under primary buttons.
  final Color glow;

  /// Colors of the moving aurora behind hero areas.
  final List<Color> aurora;

  @override
  AppPalette copyWith({
    LinearGradient? imageScrim,
    Color? accent,
    Color? textSecondary,
    Color? surfaceMuted,
    Color? brandSoft,
    Color? cardShadow,
    Color? solidFill,
    Color? onSolidFill,
    Color? hero,
    Color? heroRaised,
    Color? onHero,
    Color? onHeroMuted,
    Color? glow,
    List<Color>? aurora,
  }) {
    return AppPalette(
      imageScrim: imageScrim ?? this.imageScrim,
      accent: accent ?? this.accent,
      textSecondary: textSecondary ?? this.textSecondary,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      brandSoft: brandSoft ?? this.brandSoft,
      cardShadow: cardShadow ?? this.cardShadow,
      solidFill: solidFill ?? this.solidFill,
      onSolidFill: onSolidFill ?? this.onSolidFill,
      hero: hero ?? this.hero,
      heroRaised: heroRaised ?? this.heroRaised,
      onHero: onHero ?? this.onHero,
      onHeroMuted: onHeroMuted ?? this.onHeroMuted,
      glow: glow ?? this.glow,
      aurora: aurora ?? this.aurora,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      imageScrim: LinearGradient.lerp(imageScrim, other.imageScrim, t)!,
      accent: mix(accent, other.accent),
      textSecondary: mix(textSecondary, other.textSecondary),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      brandSoft: mix(brandSoft, other.brandSoft),
      cardShadow: mix(cardShadow, other.cardShadow),
      solidFill: mix(solidFill, other.solidFill),
      onSolidFill: mix(onSolidFill, other.onSolidFill),
      hero: mix(hero, other.hero),
      heroRaised: mix(heroRaised, other.heroRaised),
      onHero: mix(onHero, other.onHero),
      onHeroMuted: mix(onHeroMuted, other.onHeroMuted),
      glow: mix(glow, other.glow),
      aurora: t < 0.5 ? aurora : other.aurora,
    );
  }
}
