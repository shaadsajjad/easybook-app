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
class ServicesListSliver extends StatelessWidget {
  const new({
    required this.horizontalPadding,
    required this.onServiceTap,
    super.key,
  });

  final double horizontalPadding;
  final ValueChanged<Service> onServiceTap;

  @override
  Widget build(BuildContext context) {
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

        // Reloading after a filter change: keep the old cards, dimmed.
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
                return FadeSlideIn(
                  // A new key per search/filter result, so results animate in.
                  key: ValueKey(service.id),
                  index: index,
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
