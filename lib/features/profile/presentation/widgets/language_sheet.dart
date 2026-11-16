import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/app_locales.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// Bottom sheet to switch between English and Bengali. easy_localization
/// saves the choice, so it is kept after the app restarts.
abstract final class LanguageSheet {
  static String labelFor(Locale locale) =>
      locale.languageCode == AppLocales.bengali.languageCode
      ? LocaleKeys.profile_language_bengali.tr()
      : LocaleKeys.profile_language_english.tr();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (sheetContext) => SafeArea(
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
                LocaleKeys.profile_language.tr(),
                style: sheetContext.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final locale in AppLocales.supported)
                _LanguageOption(locale: locale),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const new({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final selected =
        Localizations.localeOf(context).languageCode == locale.languageCode;
    return ListTile(
      title: Text(LanguageSheet.labelFor(locale)),
      selected: selected,
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: context.colors.primary)
          : const Icon(Icons.circle_outlined),
      onTap: () async {
        await context.setLocale(locale);
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }
}
