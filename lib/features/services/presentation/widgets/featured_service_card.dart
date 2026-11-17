import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/duration_formatter.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_network_image.dart';
import 'package:easybook_app/core/widgets/pressable_scale.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/presentation/widgets/featured_badge.dart';
import 'package:easybook_app/features/services/presentation/widgets/info_pill.dart';
import 'package:easybook_app/features/services/presentation/widgets/price_tag.dart';
import 'package:flutter/material.dart';

/// A large photo card in the featured carousel.
class FeaturedServiceCard extends StatelessWidget {
  const new({
    required this.service,
    required this.onTap,
    this.parallax = 0,
    super.key,
  });

  final Service service;
  final VoidCallback onTap;

  /// -1..1 from the carousel: shifts the photo inside the card.
  final double parallax;

  @override
  Widget build(BuildContext context) {
    final onPhoto = context.palette.onHero;
    return PressableScale(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              url: service.imageUrl,
              semanticLabel: service.name,
              alignment: Alignment(parallax, 0),
            ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: onPhoto,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: InfoPill(
                          icon: AppIcons.duration,
                          color: context.palette.onHeroMuted,
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
            // The ripple sits on top of the photo.
            Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}
