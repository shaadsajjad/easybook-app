import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/app/theme_mode_cubit.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bottom sheet to pick the app theme: match the phone, light or dark.
/// The sheet stays open, so the switch can be seen happening behind it.
abstract final class ThemeSheet {
  static String labelFor(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => LocaleKeys.profile_theme_system.tr(),
    AppThemeMode.light => LocaleKeys.profile_theme_light.tr(),
    AppThemeMode.dark => LocaleKeys.profile_theme_dark.tr(),
  };

  static IconData iconFor(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => AppIcons.themeSystem,
    AppThemeMode.light => AppIcons.themeLight,
    AppThemeMode.dark => AppIcons.themeDark,
  };

  static Future<void> show(BuildContext context) {
    final cubit = context.read<ThemeModeCubit>();
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      // The sheet sits above the cubit's provider in the tree, so pass it on.
      builder: (_) => BlocProvider.value(value: cubit, child: const _Body()),
    );
  }
}

class _Body extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<ThemeModeCubit>().state;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.profile_appearance.tr(),
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                for (final mode in AppThemeMode.values) ...[
                  if (mode != AppThemeMode.values.first)
                    const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _Option(
                      mode: mode,
                      selected: mode == selected,
                      onTap: () => context.read<ThemeModeCubit>().select(mode),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A tile with the mode's icon and name; the picked one turns lime.
class _Option extends StatelessWidget {
  const new({required this.mode, required this.selected, required this.onTap});

  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = selected
        ? palette.onSolidFill
        : context.colors.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: ThemeSheet.labelFor(mode),
      child: ExcludeSemantics(
        child: PressableScale(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: AnimatedContainer(
              duration: AppDurations.medium,
              curve: AppMotion.standard,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
                horizontal: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: selected ? palette.solidFill : palette.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                children: [
                  AnimatedRotation(
                    turns: selected ? 0 : -0.25,
                    duration: AppDurations.slow,
                    curve: AppMotion.enter,
                    child: Icon(
                      ThemeSheet.iconFor(mode),
                      color: foreground,
                      size: AppSizes.iconLg,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ThemeSheet.labelFor(mode),
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
