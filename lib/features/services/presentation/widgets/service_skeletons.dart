import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/widgets/skeleton.dart';
import 'package:easybook_app/features/services/presentation/widgets/service_card.dart'
    show ServiceCard;
import 'package:flutter/material.dart';

/// Placeholder with the shape of a [ServiceCard], shown while loading.
class ServiceCardSkeleton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            SkeletonBox(
              width: AppSizes.serviceThumb,
              height: AppSizes.serviceThumb,
              radius: AppRadius.md,
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: AppSizes.skeletonShort,
                    height: AppSizes.skeletonLineSm,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  SkeletonBox(
                    width: double.infinity,
                    height: AppSizes.skeletonLineLg,
                  ),
                  SizedBox(height: AppSpacing.md),
                  SkeletonBox(
                    width: AppSizes.skeletonMedium,
                    height: AppSizes.skeletonPill,
                    radius: AppRadius.pill,
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

/// Placeholder for the featured carousel.
class FeaturedCardSkeleton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonBox(
      width: AppSizes.featuredCardWidth,
      radius: AppRadius.lg,
    );
  }
}
