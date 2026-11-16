import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';

/// Gradient card with the user's initials, name, email and phone.
class ProfileHeader extends StatelessWidget {
  const new({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final onGradient = context.colors.onPrimary;
    final soft = onGradient.withValues(alpha: 0.85);
    final phone = user.phone;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: context.palette.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.3),
            blurRadius: AppElevation.cardBlur,
            offset: const Offset(0, AppElevation.cardOffsetY),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSizes.avatar / 2,
            backgroundColor: onGradient.withValues(alpha: 0.2),
            child: Text(
              user.initials,
              style: context.textTheme.titleLarge?.copyWith(color: onGradient),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: onGradient,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _Line(icon: Icons.mail_outline_rounded, text: user.email),
                const SizedBox(height: AppSpacing.xxs),
                _Line(
                  icon: Icons.phone_outlined,
                  text: phone ?? LocaleKeys.profile_no_phone.tr(),
                  color: phone == null ? soft.withValues(alpha: 0.7) : soft,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const new({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground =
        color ?? context.colors.onPrimary.withValues(alpha: 0.85);
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm, color: foreground),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(color: foreground),
          ),
        ),
      ],
    );
  }
}
