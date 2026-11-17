import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/utils/event_transformers.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/domain/entities/service_filter.dart';
import 'package:easybook_app/features/services/domain/usecases/get_services.dart';
import 'package:equatable/equatable.dart';

part 'services_event.dart';
part 'services_state.dart';

/// The searchable, filterable, paginated list on Home.
///
/// Every filter change reloads page 1. Results that arrive after a newer
/// request started are ignored ([_requestId]), so a slow old search can
/// never overwrite a newer one.
class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  new({
    required this._getServices,
    Duration searchDebounce = AppConstants.searchDebounce,
  }) : super(const ServicesState()) {
    on<ServicesStarted>((event, emit) => _reload(state.filter, emit));
    on<ServicesRefreshed>(
      (event, emit) => _reload(state.filter, emit, forceRefresh: true),
    );
    on<ServicesSearchChanged>(
      (event, emit) => _reload(state.filter.withSearch(event.query), emit),
      transformer: debounce(searchDebounce),
    );
    on<ServicesCategorySelected>(
      (event, emit) => _reload(state.filter.withCategory(event.category), emit),
    );
    on<ServicesPriceRangeChanged>(
      (event, emit) => _reload(
        state.filter.withPriceRange(min: event.minPrice, max: event.maxPrice),
        emit,
      ),
    );
    on<ServicesFiltersCleared>(
      (event, emit) => _reload(const ServiceFilter(), emit),
    );
    on<ServicesNextPageRequested>(_onNextPageRequested);
  }

  final GetServices _getServices;
  int _requestId = 0;

  /// [forceRefresh] skips the repository's cache (pull to refresh).
  Future<void> _reload(
    ServiceFilter filter,
    Emitter<ServicesState> emit, {
    bool forceRefresh = false,
  }) async {
    final requestId = ++_requestId;
    emit(
      ServicesState(
        status: ServicesStatus.loading,
        filter: filter,
        // Pull to refresh keeps the cards on screen (dimmed). A new search
        // or filter clears them, so the list shows skeletons instead of
        // results that no longer match.
        services: forceRefresh ? state.services : const [],
      ),
    );

    final result = await _getServices(
      GetServicesParams(filter: filter, forceRefresh: forceRefresh),
    );
    if (requestId != _requestId) return;

    emit(
      result.fold(
        (failure) => ServicesState(
          status: ServicesStatus.failure,
          filter: filter,
          failure: failure,
        ),
        (page) => ServicesState(
          status: ServicesStatus.success,
          filter: filter,
          services: page.services,
          page: page.page,
          totalPages: page.totalPages,
          total: page.total,
        ),
      ),
    );
  }

  Future<void> _onNextPageRequested(
    ServicesNextPageRequested event,
    Emitter<ServicesState> emit,
  ) async {
    if (state.status != ServicesStatus.success ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }
    final requestId = _requestId;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailure: () => null));

    final result = await _getServices(
      GetServicesParams(filter: state.filter, page: state.page + 1),
    );
    // A filter change while loading more makes this page irrelevant.
    if (requestId != _requestId) return;

    emit(
      result.fold(
        (failure) => state.copyWith(
          isLoadingMore: false,
          loadMoreFailure: () => failure,
        ),
        (page) => state.copyWith(
          services: [...state.services, ...page.services],
          page: page.page,
          totalPages: page.totalPages,
          total: page.total,
          isLoadingMore: false,
        ),
      ),
    );
  }
}
