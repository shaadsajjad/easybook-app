/// Spacing on a 4-point grid.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal padding of every page.
  static const double page = 20;
}

/// Corner radii.
abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 999;
}

/// Fixed component sizes.
abstract final class AppSizes {
  static const double buttonHeight = 54;
  static const double minTapTarget = 48;
  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 28;
  static const double iconXl = 40;
  static const double avatar = 56;
  static const double navBarHeight = 72;
  static const double logoSm = 40;
  static const double logoLg = 96;
  static const double borderThin = 1;
  static const double borderThick = 1.5;
  static const double progressStroke = 2.5;
}

/// Width limits so pages look right on tablets.
abstract final class AppBreakpoints {
  static const double tablet = 600;
  static const double maxContentWidth = 720;
  static const double maxFormWidth = 480;
}

/// Shadow blur and offsets.
abstract final class AppElevation {
  static const double cardBlur = 24;
  static const double cardOffsetY = 8;
  static const double buttonBlur = 16;
  static const double buttonOffsetY = 6;
}

/// Animation durations.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration shimmer = Duration(milliseconds: 1400);
}
