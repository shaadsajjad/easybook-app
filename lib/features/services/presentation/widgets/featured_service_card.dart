import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/duration_formatter.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_network_image.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/presentation/widgets/featured_badge.dart';
import 'package:easybook_app/features/services/presentation/widgets/info_pill.dart';
import 'package:easybook_app/features/services/presentation/widgets/price_tag.dart';
import 'package:flutter/material.dart';

/// A large photo card in the featured carousel.
class FeaturedServiceCard extends StatelessWidget {
  const new({required this.service, required this.onTap, super.key});

  final Service service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onPhoto = context.colors.onPrimary;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(url: service.imageUrl, semanticLabel: service.name),
            DecoratedBox(
              decoration: BoxDecoration(gradient: context.palette.imageScrim),
            ),
            const Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: FeaturedBadge(),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: onPhoto,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: InfoPill(
                          icon: Icons.schedule_rounded,
                          color: onPhoto,
                          label: DurationFormatter.format(
                            service.durationMinutes,
                            context.localeName,
                          ),
                        ),
                      ),
                      PriceTag(price: service.price, filled: true),
                    ],
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
