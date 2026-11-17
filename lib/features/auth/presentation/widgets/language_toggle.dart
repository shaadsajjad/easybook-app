import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/app_locales.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// A compact "EN | বাং" segmented switch for the auth hero (on ink).
/// The choice is saved by easy_localization.
class LanguageToggle extends StatelessWidget {
  const new({super.key});

  static const List<(Locale, String)> _options = [
    (AppLocales.english, 'EN'),
    (AppLocales.bengali, 'বাং'),
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: LocaleKeys.auth_language.tr(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.palette.onHero.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (locale, label) in _options)
                _LanguageOption(
                  label: label,
                  selected:
                      Localizations.localeOf(context).languageCode ==
                      locale.languageCode,
                  onTap: () => context.setLocale(locale),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const new({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: AnimatedContainer(
          duration: AppDurations.medium,
          curve: AppMotion.standard,
          constraints: const BoxConstraints(
            minWidth: AppSizes.minTapTarget,
            minHeight: AppSizes.minTapTarget,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? context.palette.accent : null,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: selected
                  ? context.palette.onSolidFill
                  : context.palette.onHeroMuted,
            ),
          ),
        ),
      ),
    );
  }
}
