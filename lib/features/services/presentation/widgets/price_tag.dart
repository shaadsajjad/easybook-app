import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/utils/price_formatter.dart';
import 'package:flutter/material.dart';

/// A coral pill with the price, for example "৳500".
class PriceTag extends StatelessWidget {
  const new({required this.price, this.filled = false, super.key});

  final double price;

  /// Solid coral (on photos) instead of a light tint (on cards).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final accent = context.palette.accent;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: filled ? accent : accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        PriceFormatter.format(price, locale: context.localeName),
        style: context.textTheme.labelLarge?.copyWith(
          color: filled ? context.colors.onPrimary : accent,
        ),
      ),
    );
  }
}
