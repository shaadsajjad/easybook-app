import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/aurora_background.dart';
import 'package:easybook_app/core/widgets/pulse_rings.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';

/// An aurora card with the user's initials (in a pinging lime ring), name,
/// email and phone.
class ProfileHeader extends StatelessWidget {
  const new({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final phone = user.phone;

    return AuroraBackground(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            PulseRings(
              color: palette.accent,
              size: AppSizes.avatar,
              rings: 2,
              child: CircleAvatar(
                radius: AppSizes.avatar / 2,
                backgroundColor: palette.accent,
                child: Text(
                  user.initials,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: palette.onSolidFill,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: palette.onHero,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _Line(icon: AppIcons.email, text: user.email),
                  const SizedBox(height: AppSpacing.xxs),
                  _Line(
                    icon: AppIcons.phone,
                    text: phone ?? LocaleKeys.profile_no_phone.tr(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const new({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final foreground = context.palette.onHeroMuted;
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm - AppSpacing.xxs, color: foreground),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(color: foreground),
          ),
        ),
      ],
    );
  }
}
