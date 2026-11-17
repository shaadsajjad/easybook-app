import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/fade_slide_in.dart';
import 'package:easybook_app/core/widgets/pressable_scale.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/assistant_avatar.dart';
import 'package:flutter/material.dart';

/// The empty chat: a greeting and a few example questions to tap.
class AssistantWelcome extends StatelessWidget {
  const new({required this.firstName, required this.onPrompt, super.key});

  final String? firstName;
  final ValueChanged<String> onPrompt;

  @override
  Widget build(BuildContext context) {
    final name = firstName;
    final prompts = [
      LocaleKeys.assistant_prompt_back.tr(),
      LocaleKeys.assistant_prompt_haircut.tr(),
      LocaleKeys.assistant_prompt_home.tr(),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: ResponsiveCenter(
        maxWidth: AppBreakpoints.maxFormWidth,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            const FadeSlideIn(
              child: AssistantAvatar(size: AppSizes.logoLg * 0.75),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              name == null || name.isEmpty
                  ? LocaleKeys.assistant_welcome_title_no_name.tr()
                  : LocaleKeys.assistant_welcome_title.tr(
                      namedArgs: {'name': name},
                    ),
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              LocaleKeys.assistant_welcome_message.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final (index, prompt) in prompts.indexed) ...[
              FadeSlideIn(
                index: index + 1,
                child: _PromptCard(text: prompt, onTap: () => onPrompt(prompt)),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const new({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  AppIcons.prompt,
                  size: AppSizes.iconSm,
                  color: context.colors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(text, style: context.textTheme.bodyMedium),
                ),
                Icon(
                  AppIcons.openExternal,
                  size: AppSizes.iconSm,
                  color: context.palette.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
