import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/section_header.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/presentation/bloc/categories_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/featured_services_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/services_bloc.dart';
import 'package:easybook_app/features/services/presentation/widgets/category_chips.dart';
import 'package:easybook_app/features/services/presentation/widgets/featured_section.dart';
import 'package:easybook_app/features/services/presentation/widgets/home_header.dart';
import 'package:easybook_app/features/services/presentation/widgets/price_filter_sheet.dart';
import 'package:easybook_app/features/services/presentation/widgets/service_search_bar.dart';
import 'package:easybook_app/features/services/presentation/widgets/services_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Home: greeting, search, categories, featured carousel and all services.
class HomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ServicesBloc>()..add(const ServicesStarted()),
        ),
        BlocProvider(
          create: (_) {
            final cubit = getIt<FeaturedServicesCubit>();
            unawaited(cubit.load());
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) {
            final cubit = getIt<CategoriesCubit>();
            unawaited(cubit.load());
            return cubit;
          },
        ),
      ],
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const new({super.key});

  /// Start loading the next page this many pixels before the end.
  static const double loadMoreThreshold = 600;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.extentAfter < HomeView.loadMoreThreshold) {
      // The bloc ignores this when there is no next page or one is loading.
      context.read<ServicesBloc>().add(const ServicesNextPageRequested());
    }
  }

  Future<void> _refresh() async {
    final bloc = context.read<ServicesBloc>()..add(const ServicesRefreshed());
    unawaited(context.read<FeaturedServicesCubit>().load());
    unawaited(context.read<CategoriesCubit>().load());
    await bloc.stream.firstWhere(
      (state) => state.status != ServicesStatus.loading,
    );
  }

  Future<void> _openPriceFilter() async {
    final bloc = context.read<ServicesBloc>();
    final filter = bloc.state.filter;
    final range = await PriceFilterSheet.show(context, (
      min: filter.minPrice,
      max: filter.maxPrice,
    ));
    if (range == null) return;
    bloc.add(
      ServicesPriceRangeChanged(minPrice: range.min, maxPrice: range.max),
    );
  }

  void _openService(Service service) {
    unawaited(
      context.push(AppRoutes.serviceDetailPath(service.id), extra: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Center the content on tablets; phones get the normal page padding.
    final width = MediaQuery.sizeOf(context).width;
    final inset = math.max(
      AppSpacing.page,
      (width - AppBreakpoints.maxContentWidth) / 2,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: BlocSelector<ServicesBloc, ServicesState, bool>(
                  selector: (state) => state.filter.hasPriceRange,
                  builder: (context, hasPriceFilter) => HomeHeader(
                    searchBar: ServiceSearchBar(
                      hasPriceFilter: hasPriceFilter,
                      onFilterPressed: _openPriceFilter,
                      onChanged: (query) => context.read<ServicesBloc>().add(
                        ServicesSearchChanged(query),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              SliverToBoxAdapter(
                child: CategoryChips(horizontalPadding: inset),
              ),
              SliverToBoxAdapter(
                child: BlocSelector<ServicesBloc, ServicesState, bool>(
                  selector: (state) => state.filter.isActive,
                  builder: (context, isFiltering) => isFiltering
                      ? const SizedBox.shrink()
                      : FeaturedSection(
                          horizontalPadding: inset,
                          onServiceTap: _openService,
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    inset - AppSpacing.page,
                    AppSpacing.xl,
                    inset - AppSpacing.page,
                    AppSpacing.md,
                  ),
                  child: const _ListTitle(),
                ),
              ),
              ServicesListSliver(
                horizontalPadding: inset,
                onServiceTap: _openService,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "All services", or "Results · 3 found" while searching or filtering.
class _ListTitle extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesBloc, ServicesState>(
      buildWhen: (previous, current) =>
          previous.filter.isActive != current.filter.isActive ||
          previous.total != current.total ||
          previous.status != current.status,
      builder: (context, state) {
        if (!state.filter.isActive) {
          return SectionHeader(title: LocaleKeys.services_all_services.tr());
        }
        final count = NumberFormat.decimalPattern(context.localeName)
            .format(state.total);
        return SectionHeader(
          title: LocaleKeys.services_results.tr(),
          trailing: state.status == ServicesStatus.success
              ? Text(
                  LocaleKeys.services_results_count.tr(
                    namedArgs: {'count': count},
                  ),
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                )
              : null,
        );
      },
    );
  }
}
