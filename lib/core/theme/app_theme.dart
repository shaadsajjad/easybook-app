import 'package:easybook_app/core/theme/app_colors.dart';
import 'package:easybook_app/core/theme/app_page_transitions.dart';
import 'package:easybook_app/core/theme/app_palette.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/theme/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Light and dark Material 3 themes with every component styled centrally.
///
/// The look is bold: ink hero areas, electric lime calls to action with
/// ink text, pill-shaped buttons and big rounded cards.
abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceMuted: AppColors.lightSurfaceMuted,
    outline: AppColors.lightOutline,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    primary: AppColors.limeDeep,
    onPrimary: AppColors.white,
    error: AppColors.error,
    palette: AppPalette.light,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceMuted: AppColors.darkSurfaceMuted,
    outline: AppColors.darkOutline,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    primary: AppColors.lime,
    onPrimary: AppColors.ink,
    error: AppColors.errorLight,
    palette: AppPalette.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceMuted,
    required Color outline,
    required Color textPrimary,
    required Color textSecondary,
    required Color primary,
    required Color onPrimary,
    required Color error,
    required AppPalette palette,
  }) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.lime,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: palette.brandSoft,
          onPrimaryContainer: primary,
          secondary: primary,
          tertiary: palette.accent,
          error: error,
          surface: surface,
          onSurface: textPrimary,
          onSurfaceVariant: textSecondary,
          surfaceContainerHighest: surfaceMuted,
          outline: outline,
          outlineVariant: outline,
        );

    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final textTheme = AppTextStyles.textTheme(
      base: base.textTheme,
      primary: textPrimary,
      secondary: textSecondary,
    );

    const buttonShape = StadiumBorder();
    const buttonSize = Size.fromHeight(AppSizes.buttonHeight);
    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      extensions: [palette],
      splashFactory: InkRipple.splashFactory,
      // Smooth, platform-appropriate page transitions.
      // Zoom + fade + rise (see app_page_transitions). iOS keeps the
      // native slide so swipe-back still works.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: background,
        foregroundColor: textPrimary,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          backgroundColor: palette.solidFill,
          foregroundColor: palette.onSolidFill,
          disabledBackgroundColor: surfaceMuted,
          disabledForegroundColor: textSecondary,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          foregroundColor: textPrimary,
          backgroundColor: surface,
          side: BorderSide(color: outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
          textStyle: textTheme.labelLarge,
          shape: buttonShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(AppSizes.minTapTarget),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + AppSpacing.xxs,
        ),
        border: inputBorder(AppColors.transparent),
        enabledBorder: inputBorder(AppColors.transparent),
        disabledBorder: inputBorder(AppColors.transparent),
        focusedBorder: inputBorder(textPrimary, AppSizes.borderThick),
        errorBorder: inputBorder(error),
        focusedErrorBorder: inputBorder(error, AppSizes.borderThick),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        errorMaxLines: 3,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: outline),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: palette.solidFill,
        showCheckmark: false,
        disabledColor: surfaceMuted,
        side: WidgetStateBorderSide.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? BorderSide(color: palette.solidFill)
              : BorderSide(color: outline),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        labelStyle: textTheme.labelLarge?.copyWith(color: textPrimary),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: palette.onSolidFill,
        ),
        checkmarkColor: palette.onSolidFill,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppSizes.navBarHeight,
        backgroundColor: surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        indicatorColor: palette.accent,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            letterSpacing: 0.2,
            color: states.contains(WidgetState.selected)
                ? textPrimary
                : textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: AppSizes.iconMd,
            color: states.contains(WidgetState.selected)
                ? palette.onSolidFill
                : textSecondary,
          ),
        ),
      ),
      // A segmented control: an ink "thumb" sliding on a muted track.
      tabBarTheme: TabBarThemeData(
        labelColor: palette.onHero,
        unselectedLabelColor: textSecondary,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.transparent,
        overlayColor: const WidgetStatePropertyAll(AppColors.transparent),
        splashFactory: NoSplash.splashFactory,
        indicator: BoxDecoration(
          color: palette.hero,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.hero,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: palette.onHero),
        actionTextColor: palette.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        iconColor: textSecondary,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: AppColors.transparent,
        showDragHandle: true,
        dragHandleColor: outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: palette.accent,
        textColor: palette.onSolidFill,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: textPrimary,
        refreshBackgroundColor: surface,
      ),
    );
  }
}
