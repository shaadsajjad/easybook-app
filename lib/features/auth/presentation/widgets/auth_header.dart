import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_logo.dart';
import 'package:easybook_app/features/auth/presentation/widgets/language_toggle.dart';
import 'package:flutter/material.dart';

/// The gradient hero at the top of the login and register screens.
class AuthHeader extends StatelessWidget {
  const new({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final onGradient = context.colors.onPrimary;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: context.palette.brandGradient,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: onGradient.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const AppLogo(
                      size: AppSizes.logoSm,
                      showBackground: false,
                    ),
                  ),
                  const Spacer(),
                  const LanguageToggle(),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                title,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: onGradient,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: onGradient.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
