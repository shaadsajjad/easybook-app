import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/widgets/skeleton.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/booking_card.dart'
    show BookingCard;
import 'package:flutter/material.dart';

/// Placeholder with the shape of a [BookingCard].
class BookingCardSkeleton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            SkeletonBox(
              width: AppSizes.dayChipWidth,
              height: AppSizes.dayChipWidth * 1.4,
              radius: AppRadius.md,
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: double.infinity, height: 18),
                  SizedBox(height: AppSpacing.sm),
                  SkeletonBox(width: 140, height: 14),
                  SizedBox(height: AppSpacing.md),
                  SkeletonBox(width: 160, height: 22, radius: AppRadius.pill),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
