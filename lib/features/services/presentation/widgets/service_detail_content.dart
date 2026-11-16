import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/duration_formatter.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/utils/price_formatter.dart';
import 'package:easybook_app/core/widgets/app_network_image.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/presentation/widgets/featured_badge.dart';
import 'package:easybook_app/features/services/presentation/widgets/service_card.dart';
import 'package:flutter/material.dart';

/// Scrollable body of the detail page: a collapsing photo, the name, three
/// fact tiles (duration, price, category) and the description.
class ServiceDetailContent extends StatelessWidget {
  const new({required this.service, super.key});

  final Service service;

  @override
  Widget build(BuildContext context) {
    final locale = context.localeName;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: AppSizes.detailImageHeight,
          pinned: true,
          stretch: true,
          leading: const _RoundBackButton(),
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: serviceHeroTag(service.id),
              child: AppNetworkImage(
                url: service.imageUrl,
                semanticLabel: service.name,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ResponsiveCenter(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service.isFeatured) ...[
                  const FeaturedBadge(),
                  const SizedBox(height: AppSpacing.md),
                ],
                Text(service.name, style: context.textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.xl),
                // Same height for all three tiles, even when one wraps.
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _FactTile(
                          icon: Icons.schedule_rounded,
                          label: LocaleKeys.services_detail_duration.tr(),
                          value: DurationFormatter.format(
                            service.durationMinutes,
                            locale,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _FactTile(
                          icon: Icons.payments_outlined,
                          label: LocaleKeys.services_detail_price.tr(),
                          value: PriceFormatter.format(
                            service.price,
                            locale: locale,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _FactTile(
                          icon: Icons.category_outlined,
                          label: LocaleKeys.services_detail_category.tr(),
                          value: service.category,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  LocaleKeys.services_detail_about.tr(),
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  service.description,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FactTile extends StatelessWidget {
  const new({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.colors.primary, size: AppSizes.iconMd),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: context.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

/// A back button in a white circle, readable on top of any photo.
class _RoundBackButton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: IconButton.filled(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        style: IconButton.styleFrom(
          backgroundColor: context.colors.surface,
          foregroundColor: context.colors.onSurface,
        ),
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
