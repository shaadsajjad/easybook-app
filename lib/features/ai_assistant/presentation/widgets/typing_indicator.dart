import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/pulse_rings.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/assistant_avatar.dart';
import 'package:flutter/material.dart';

/// Three bouncing dots in an assistant bubble while waiting for a reply.
class TypingIndicator extends StatefulWidget {
  const new({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.shimmer,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: LocaleKeys.assistant_typing.tr(),
      liveRegion: true,
      child: Row(
        children: [
          // The avatar pings while the assistant is thinking.
          PulseRings(
            color: context.palette.accent,
            size: AppSizes.chatAvatar,
            rings: 2,
            child: const AssistantAvatar(),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md + AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border.all(color: context.colors.outline),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [for (var i = 0; i < 3; i++) _dot(context, i)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(BuildContext context, int index) {
    // Each dot rises a little later than the one before it.
    final phase = (_controller.value - index * 0.15) * 2 * math.pi;
    final lift = math.max(0, math.sin(phase)) * AppSpacing.sm;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: Transform.translate(
        offset: Offset(0, -lift),
        child: Container(
          width: AppSizes.typingDot,
          height: AppSizes.typingDot,
          decoration: BoxDecoration(
            color: context.colors.onSurface.withValues(
              alpha: 0.3 + lift / AppSpacing.sm * 0.7,
            ),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
