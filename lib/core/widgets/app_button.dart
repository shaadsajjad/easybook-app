import 'package:easybook_app/core/theme/app_colors.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, text }

/// The app's button. `primary` is the gradient call to action.
///
/// While [isLoading] is true the button shows a spinner and ignores taps,
/// so a request can't be sent twice.
class AppButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final callback = _enabled ? onPressed : null;
    return switch (variant) {
      AppButtonVariant.primary => _GradientButton(
        onPressed: callback,
        child: _content(context, AppColors.white),
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: callback,
        child: _content(context, context.colors.primary),
      ),
      AppButtonVariant.text => TextButton(
        onPressed: callback,
        child: _content(context, context.colors.primary),
      ),
    };
  }

  Widget _content(BuildContext context, Color color) {
    if (isLoading) {
      return SizedBox.square(
        dimension: AppSizes.iconMd,
        child: CircularProgressIndicator(
          strokeWidth: AppSizes.progressStroke,
          color: color,
        ),
      );
    }
    final text = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (icon == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconSm),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: text),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const new({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final palette = context.palette;
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.55,
      duration: AppDurations.fast,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: palette.brandGradient,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.35),
                    blurRadius: AppElevation.buttonBlur,
                    offset: const Offset(0, AppElevation.buttonOffsetY),
                  ),
                ]
              : null,
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.transparent,
            disabledBackgroundColor: AppColors.transparent,
            foregroundColor: AppColors.white,
            disabledForegroundColor: AppColors.white,
            shadowColor: AppColors.transparent,
          ),
          child: child,
        ),
      ),
    );
  }
}
