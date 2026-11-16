import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/widgets/section_header.dart';
import 'package:easybook_app/core/widgets/skeleton.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/presentation/bloc/featured_services_cubit.dart';
import 'package:easybook_app/features/services/presentation/widgets/featured_service_card.dart';
import 'package:easybook_app/features/services/presentation/widgets/service_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "Featured" title and a horizontal carousel of big photo cards.
/// If featured services fail or there are none, the section is hidden:
/// the main list below has its own error and empty states.
class FeaturedSection extends StatelessWidget {
  const new({
    required this.horizontalPadding,
    required this.onServiceTap,
    super.key,
  });

  final double horizontalPadding;
  final ValueChanged<Service> onServiceTap;

  @override
  Widget build(BuildContext context) {
    // Taller cards when the user enlarges text, so nothing gets cut off.
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.6);
    final height = AppSizes.featuredCardHeight * textScale;

    return BlocBuilder<FeaturedServicesCubit, FeaturedServicesState>(
      builder: (context, state) {
        final isLoading =
            state.status == FeaturedStatus.loading && state.services.isEmpty;
        if (!isLoading && state.services.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: LocaleKeys.services_featured.tr()),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: height,
              child: isLoading
                  ? Shimmer(child: _row(3, (_) => const FeaturedCardSkeleton()))
                  : _row(
                      state.services.length,
                      (index) => FeaturedServiceCard(
                        service: state.services[index],
                        onTap: () => onServiceTap(state.services[index]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _row(int count, Widget Function(int index) builder) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.lg),
      itemBuilder: (_, index) =>
          SizedBox(width: AppSizes.featuredCardWidth, child: builder(index)),
    );
  }
}
