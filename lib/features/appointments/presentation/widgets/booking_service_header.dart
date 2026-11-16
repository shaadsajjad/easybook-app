import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/duration_formatter.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_network_image.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/presentation/widgets/info_pill.dart';
import 'package:easybook_app/features/services/presentation/widgets/price_tag.dart';
import 'package:flutter/material.dart';

/// "What you are booking": photo, name, duration and price.
class BookingServiceHeader extends StatelessWidget {
  const new({required this.service, super.key});

  final Service service;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox.square(
                dimension: AppSizes.avatar,
                child: AppNetworkImage(url: service.imageUrl),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  InfoPill(
                    icon: Icons.schedule_rounded,
                    label: DurationFormatter.format(
                      service.durationMinutes,
                      context.localeName,
                    ),
                  ),
                ],
              ),
            ),
            PriceTag(price: service.price),
          ],
        ),
      ),
    );
  }
}
