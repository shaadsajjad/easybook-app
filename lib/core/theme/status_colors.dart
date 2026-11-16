import 'package:easybook_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The tone of a status chip. Features map their own statuses to a tone
/// (for example PENDING -> warning), so core does not depend on features.
enum StatusTone { warning, info, success, neutral }

/// Foreground color for each tone, in light and dark mode. The chip
/// background is the same color at low opacity.
abstract final class StatusColors {
  static Color foreground(StatusTone tone, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return switch (tone) {
      StatusTone.warning => isDark ? AppColors.amberLight : AppColors.amber,
      StatusTone.info =>
        isDark ? AppColors.brandIndigoLight : AppColors.brandIndigo,
      StatusTone.success => isDark ? AppColors.greenLight : AppColors.green,
      StatusTone.neutral => isDark ? AppColors.slateLight : AppColors.slate,
    };
  }

  static Color background(StatusTone tone, Brightness brightness) =>
      foreground(tone, brightness).withValues(alpha: 0.14);
}
