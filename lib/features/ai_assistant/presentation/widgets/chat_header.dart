import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/aurora_background.dart';
import 'package:easybook_app/core/widgets/pulse_rings.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/assistant_avatar.dart';
import 'package:flutter/material.dart';

/// "EasyBook Assistant" title bar at the top of the chat.
class ChatHeader extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // An aurora hero bar with a "live" lime dot next to the title.
    return AuroraBackground(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppRadius.xl),
      ),
      intensity: 0.7,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xl,
            AppSpacing.page,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              const AssistantAvatar(size: AppSizes.avatar * 0.8),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            LocaleKeys.assistant_title.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: palette.onHero,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        PulseRings(
                          color: palette.accent,
                          size: AppSpacing.sm,
                          rings: 2,
                          child: Container(
                            width: AppSpacing.sm,
                            height: AppSpacing.sm,
                            decoration: BoxDecoration(
                              color: palette.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      LocaleKeys.assistant_subtitle.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: palette.onHeroMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
