import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

enum InlineBannerTone { error, info }

/// A message inside a form or page (not a full-screen state), for example
/// "Invalid email or password" above the login button.
class InlineBanner extends StatelessWidget {
  const new({
    required this.message,
    this.tone = InlineBannerTone.error,
    super.key,
  });

  final String message;
  final InlineBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      InlineBannerTone.error => context.colors.error,
      InlineBannerTone.info => context.colors.primary,
    };
    final icon = switch (tone) {
      InlineBannerTone.error => AppIcons.error,
      InlineBannerTone.info => AppIcons.info,
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: AppSizes.iconSm + AppSpacing.xxs),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
