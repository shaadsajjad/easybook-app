import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/duration_formatter.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_network_image.dart';
import 'package:easybook_app/core/widgets/pressable_scale.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/presentation/widgets/info_pill.dart';
import 'package:easybook_app/features/services/presentation/widgets/price_tag.dart';
import 'package:flutter/material.dart';

/// Hero tag shared by the list card and the detail page image.
String serviceHeroTag(String id) => 'service-image-$id';

/// A row in the services list: photo, category, name, duration and price.
class ServiceCard extends StatelessWidget {
  const new({required this.service, required this.onTap, super.key});

  final Service service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Hero(
                  tag: serviceHeroTag(service.id),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: SizedBox.square(
                      dimension: AppSizes.serviceThumb,
                      child: AppNetworkImage(url: service.imageUrl),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _Details(service: service)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const new({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                service.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (service.isFeatured) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(
                AppIcons.featured,
                size: AppSizes.iconSm - AppSpacing.xxs,
                color: context.colors.primary,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          service.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: InfoPill(
                icon: AppIcons.duration,
                label: DurationFormatter.format(
                  service.durationMinutes,
                  context.localeName,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            PriceTag(price: service.price, filled: true),
          ],
        ),
      ],
    );
  }
}
