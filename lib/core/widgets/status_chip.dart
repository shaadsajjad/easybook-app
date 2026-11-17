import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/theme/status_colors.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// A small pill showing a status. Color always comes with a text label,
/// never color alone.
class StatusChip extends StatelessWidget {
  const new({required this.label, required this.tone, super.key});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final foreground = StatusColors.foreground(tone, brightness);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xxs,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: StatusColors.background(tone, brightness),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSpacing.xs + AppSpacing.xxs,
            height: AppSpacing.xs + AppSpacing.xxs,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs + AppSpacing.xxs / 2),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
