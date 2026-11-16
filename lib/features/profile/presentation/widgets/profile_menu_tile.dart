import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// A row in the profile menu: tinted icon, title, subtitle and a chevron.
class ProfileMenuTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  /// Red styling for actions like "Log out".
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? context.colors.error : context.colors.primary;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: color, size: AppSizes.iconMd),
      ),
      title: Text(
        title,
        style: destructive
            ? context.textTheme.titleSmall?.copyWith(color: color)
            : null,
      ),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: destructive
          ? null
          : Icon(
              Icons.chevron_right_rounded,
              color: context.palette.textSecondary,
            ),
    );
  }
}
