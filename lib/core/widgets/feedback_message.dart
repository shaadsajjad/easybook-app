import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_button.dart';
import 'package:easybook_app/core/widgets/empty_view.dart' show EmptyView;
import 'package:easybook_app/core/widgets/error_view.dart' show ErrorView;
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:flutter/material.dart';

/// Shared layout of [ErrorView] and [EmptyView]: a tinted icon bubble, a
/// title, a message and an optional button. Scrolls when space is tight
/// (small screens, large text).
class FeedbackMessage extends StatelessWidget {
  const new({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ResponsiveCenter(
          maxWidth: AppBreakpoints.maxFormWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: AppSizes.iconXl, color: iconColor),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  icon: actionIcon,
                  variant: AppButtonVariant.secondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
