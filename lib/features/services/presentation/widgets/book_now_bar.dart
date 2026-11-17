import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/utils/price_formatter.dart';
import 'package:easybook_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Sticky bottom bar on the detail page: total price and "Book now".
class BookNowBar extends StatelessWidget {
  const new({required this.price, required this.onBook, super.key});

  final double price;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // An ink panel with rounded top corners.
        color: context.palette.hero,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              children: [
                // The price takes what it needs, up to 40% of the row, and
                // shrinks on small phones with large text. The Book button
                // always gets the rest.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.4,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.services_starting_at.tr(),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.palette.onHeroMuted,
                          ),
                        ),
                        Text(
                          PriceFormatter.format(
                            price,
                            locale: context.localeName,
                          ),
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: context.palette.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: AppButton(
                    label: LocaleKeys.services_book_now.tr(),
                    icon: AppIcons.calendar,
                    onPressed: onBook,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
