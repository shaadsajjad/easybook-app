import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// "★ Featured" label on photos.
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
        gradient: context.palette.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: AppSizes.iconSm,
            color: context.colors.onPrimary,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            LocaleKeys.services_featured_badge.tr(),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
