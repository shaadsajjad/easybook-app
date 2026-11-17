import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// "★ Featured" label: a small white tag with a gold star.
class FeaturedBadge extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.palette.accent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.featured,
            size: AppSizes.iconSm - AppSpacing.xxs,
            color: context.palette.onSolidFill,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            LocaleKeys.services_featured_badge.tr(),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.palette.onSolidFill,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
