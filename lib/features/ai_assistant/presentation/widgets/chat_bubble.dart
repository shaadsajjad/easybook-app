import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/suggested_service.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/assistant_avatar.dart';
import 'package:flutter/material.dart';

/// One message. The user's are on the right in ink; the
/// assistant's are on the left, with tappable service chips underneath.
class ChatBubble extends StatelessWidget {
  const new({required this.message, required this.onServiceTap, super.key});

  final ChatMessage message;
  final ValueChanged<SuggestedService> onServiceTap;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final maxWidth =
        MediaQuery.sizeOf(context).width * AppSizes.chatBubbleWidthFactor;
    const radius = Radius.circular(AppRadius.lg);
    const tail = Radius.circular(AppRadius.sm / 2);

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isUser ? context.palette.hero : context.colors.surface,
          border: isUser ? null : Border.all(color: context.colors.outline),
          borderRadius: BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: isUser ? radius : tail,
            bottomRight: isUser ? tail : radius,
          ),
        ),
        child: SelectableText(
          message.text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: isUser ? context.palette.onHero : null,
          ),
        ),
      ),
    );

    if (isUser) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AssistantAvatar(),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bubble,
              if (message.suggestions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final service in message.suggestions)
                      _ServiceChip(
                        service: service,
                        onTap: () => onServiceTap(service),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const new({required this.service, required this.onTap});

  final SuggestedService service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: LocaleKeys.assistant_open_service.tr(
        namedArgs: {'service': service.name},
      ),
      child: ExcludeSemantics(
        child: ActionChip(
          onPressed: onTap,
          avatar: Icon(
            AppIcons.openExternal,
            size: AppSizes.iconSm,
            color: context.colors.primary,
          ),
          label: Text(service.name),
          side: BorderSide(color: context.colors.outline),
          backgroundColor: context.colors.surface,
          labelStyle: context.textTheme.labelLarge?.copyWith(
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }
}
