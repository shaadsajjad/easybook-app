import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/utils/price_formatter.dart';
import 'package:flutter/material.dart';

/// The price, for example "৳500": bold text on cards, or a lime pill with
/// ink text when [filled] (on photos and highlights).
class PriceTag extends StatelessWidget {
  const new({required this.price, this.filled = false, super.key});

  final double price;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Text(
      PriceFormatter.format(price, locale: context.localeName),
      maxLines: 1,
      style: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: filled ? palette.onSolidFill : context.colors.onSurface,
      ),
    );
    if (!filled) return text;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: palette.solidFill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: text,
    );
  }
}
