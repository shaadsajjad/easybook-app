import 'package:flutter/animation.dart';

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

  /// Space between the status bar (or camera cutout) and a page's first
  /// content, on top of the safe-area inset.
  static const double pageTop = xxl + xs;
}

/// Corner radii.
abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 30;
  static const double pill = 999;
}

/// Fixed component sizes.
abstract final class AppSizes {
  static const double buttonHeight = 56;
  static const double minTapTarget = 48;
  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 28;
  static const double iconXl = 40;
  static const double avatar = 56;
  static const double avatarSm = 44;
  static const double navBarHeight = 68;
  static const double navIcon = 24;
  static const double logoSm = 40;
  static const double logoLg = 96;
  static const double borderThin = 1;
  static const double borderThick = 1.5;
  static const double progressStroke = 2.5;

  // Service cards.
  static const double serviceThumb = 88;
  static const double featuredCardWidth = 300;
  static const double featuredCardHeight = 260;
  static const double detailImageHeight = 380;
  static const double chipRowHeight = 48;
  static const double filterDot = 8;

  // Skeleton placeholder line widths.
  static const double skeletonShort = 80;
  static const double skeletonMedium = 140;
  static const double skeletonLong = 160;
  static const double skeletonLineSm = 12;
  static const double skeletonLineMd = 14;
  static const double skeletonLineLg = 18;
  static const double skeletonPill = 22;

  /// Same size as the glyph on the native launch screens.
  static const double splashLogo = 140;

  // Booking.
  static const double dayChipWidth = 64;
  static const double slotChipMinWidth = 96;
  static const double confirmationIcon = 112;
  static const double checkStroke = 6;

  // Assistant chat.
  static const double chatAvatar = 32;
  static const double typingDot = 8;

  /// A bubble takes at most this share of the screen width.
  static const double chatBubbleWidthFactor = 0.78;
}

/// Width limits so pages look right on tablets.
abstract final class AppBreakpoints {
  static const double tablet = 600;
  static const double maxContentWidth = 720;
  static const double maxFormWidth = 480;
}

/// Shadow blur and offsets. Shadows are soft and rare: most surfaces are
/// separated by a hairline border instead.
abstract final class AppElevation {
  static const double cardBlur = 16;
  static const double cardOffsetY = 4;
}

/// Animation durations.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration entrance = Duration(milliseconds: 650);
  static const Duration page = Duration(milliseconds: 480);
  static const Duration check = Duration(milliseconds: 900);
  static const Duration confetti = Duration(milliseconds: 2400);
  static const Duration shimmer = Duration(milliseconds: 1400);
  static const Duration shine = Duration(milliseconds: 3200);
  static const Duration pulse = Duration(milliseconds: 1800);
  static const Duration logo = Duration(milliseconds: 1400);

  /// One full drift of the aurora behind hero areas.
  static const Duration aurora = Duration(seconds: 12);

  /// Delay between items of a staggered list entrance.
  static const Duration stagger = Duration(milliseconds: 70);
}

/// Animation curves and amounts, so motion feels the same everywhere.
abstract final class AppMotion {
  /// Springy curve for things entering the screen (a small overshoot).
  static const Curve enter = Curves.easeOutBack;

  /// Smooth decelerating curve for fades and slides.
  static const Curve smooth = Curves.easeOutCubic;

  /// Standard curve for state changes (selection, size, color).
  static const Curve standard = Curves.easeInOutCubic;

  /// Bouncy curve for selections and pops.
  static const Curve pop = Curves.elasticOut;

  /// How far (in logical pixels) items rise while fading in.
  static const double entranceOffset = 36;

  /// Scale items start from while entering.
  static const double entranceScale = 0.9;

  /// Scale of a card or button while pressed.
  static const double pressedScale = 0.94;

  /// How far the page must scroll in one direction before the floating
  /// navigation bar hides (scrolling down) or comes back (scrolling up).
  static const double navToggleDistance = 24;

  /// Only the first few list items are staggered; later ones (built while
  /// scrolling) appear without extra delay.
  static const int maxStaggeredItems = 8;
}
