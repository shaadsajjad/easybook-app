import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_logo.dart';
import 'package:easybook_app/core/widgets/aurora_background.dart';
import 'package:easybook_app/core/widgets/fade_slide_in.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/auth/presentation/widgets/language_toggle.dart';
import 'package:flutter/material.dart';

/// The aurora hero at the top of the login and register screens: logo,
/// language switch, then a big title and subtitle.
class AuthHeader extends StatelessWidget {
  const new({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AuroraBackground(
      child: SafeArea(
        bottom: false,
        child: ResponsiveCenter(
          maxWidth: AppBreakpoints.maxFormWidth,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.xxxl + AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                offset: -AppMotion.entranceOffset,
                child: Row(
                  children: [
                    const AppLogo(size: AppSizes.logoSm),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        LocaleKeys.app_name.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleLarge?.copyWith(
                          color: palette.onHero,
                        ),
                      ),
                    ),
                    const LanguageToggle(),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              FadeSlideIn(
                index: 1,
                child: Text(
                  title,
                  style: context.textTheme.displaySmall?.copyWith(
                    color: palette.onHero,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FadeSlideIn(
                index: 2,
                child: Text(
                  subtitle,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: palette.onHeroMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
