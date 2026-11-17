import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/empty_view.dart';
import 'package:easybook_app/core/widgets/error_view.dart';
import 'package:easybook_app/core/widgets/fade_slide_in.dart';
import 'package:easybook_app/core/widgets/skeleton.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/presentation/bloc/services_bloc.dart';
import 'package:easybook_app/features/services/presentation/widgets/service_card.dart';
import 'package:easybook_app/features/services/presentation/widgets/service_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The services list with all its states: skeletons while loading, an
/// error with retry, an empty state, the cards, and a "load more" footer.
class ServicesListSliver extends StatefulWidget {
  const new({
    required this.horizontalPadding,
    required this.onServiceTap,
    super.key,
  });

  final double horizontalPadding;
  final ValueChanged<Service> onServiceTap;

  @override
  State<ServicesListSliver> createState() => _ServicesListSliverState();
}

class _ServicesListSliverState extends State<ServicesListSliver> {
  /// Cards that already played their entrance in the current results.
  /// A card plays it once: scrolling it away and back, loading more pages
  /// or pulling to refresh never replays it. New results (a new search or
  /// filter, shown after the skeletons) start fresh.
  final Set<String> _played = {};

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.horizontalPadding;
    final onServiceTap = widget.onServiceTap;
    return BlocBuilder<ServicesBloc, ServicesState>(
      builder: (context, state) {
        final bloc = context.read<ServicesBloc>();
        final padding = EdgeInsets.symmetric(horizontal: horizontalPadding);

        if (state.status == ServicesStatus.failure) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(
              message: state.failure?.displayMessage ?? '',
              onRetry: () => bloc.add(const ServicesRefreshed()),
            ),
          );
        }
        if (state.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              icon: AppIcons.noResults,
              title: LocaleKeys.services_empty_title.tr(),
              message: LocaleKeys.services_empty_message.tr(),
              actionLabel: state.filter.isActive
                  ? LocaleKeys.services_clear_filters.tr()
                  : null,
              onAction: () => bloc.add(const ServicesFiltersCleared()),
            ),
          );
        }
        final isFirstLoad =
            state.services.isEmpty &&
            (state.status == ServicesStatus.loading ||
                state.status == ServicesStatus.initial);
        if (isFirstLoad) {
          _played.clear();
          return SliverPadding(
            padding: padding,
            sliver: SliverList.separated(
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, _) =>
                  const Shimmer(child: ServiceCardSkeleton()),
            ),
          );
        }

        // Pull to refresh: keep the cards, dimmed, until the new ones arrive.
        final isReloading = state.status == ServicesStatus.loading;
        return SliverPadding(
          padding: padding.copyWith(bottom: AppSpacing.xxl),
          sliver: SliverOpacity(
            opacity: isReloading ? 0.5 : 1,
            sliver: SliverList.separated(
              itemCount: state.services.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index == state.services.length) {
                  return _ListFooter(state: state);
                }
                final service = state.services[index];
                // Only the first screenful animates, each card once. Cards
                // built later while scrolling just appear.
                final animate =
                    index < AppMotion.maxStaggeredItems &&
                    _played.add(service.id);
                return FadeSlideIn(
                  key: ValueKey(service.id),
                  index: index,
                  animate: animate,
                  // A calm fade and rise: no zoom, no overshoot.
                  offset: AppSpacing.lg,
                  scaleFrom: 1,
                  curve: AppMotion.smooth,
                  child: ServiceCard(
                    service: service,
                    onTap: () => onServiceTap(service),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ListFooter extends StatelessWidget {
  const new({required this.state});

  final ServicesState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: AppSizes.progressStroke,
          ),
        ),
      );
    }
    if (state.loadMoreFailure != null) {
      return Column(
        children: [
          Text(
            LocaleKeys.services_load_more_error.tr(),
            style: context.textTheme.bodySmall,
          ),
          TextButton.icon(
            onPressed: () => context.read<ServicesBloc>().add(
              const ServicesNextPageRequested(),
            ),
            icon: const Icon(AppIcons.retry),
            label: Text(LocaleKeys.common_retry.tr()),
          ),
        ],
      );
    }
    return const SizedBox(height: AppSpacing.lg);
  }
}
