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
      InlineBannerTone.error => Icons.error_outline_rounded,
      InlineBannerTone.info => Icons.info_outline_rounded,
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: AppSizes.iconMd),
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
