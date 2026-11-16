part of 'services_bloc.dart';

enum ServicesStatus { initial, loading, success, failure }

final class ServicesState extends Equatable {
  const new({
    this.status = ServicesStatus.initial,
    this.filter = const ServiceFilter(),
    this.services = const [],
    this.page = 0,
    this.totalPages = 0,
    this.total = 0,
    this.isLoadingMore = false,
    this.failure,
    this.loadMoreFailure,
  });

  final ServicesStatus status;
  final ServiceFilter filter;
  final List<Service> services;
  final int page;
  final int totalPages;
  final int total;
  final bool isLoadingMore;

  /// Why the first page failed (full-screen error).
  final Failure? failure;

  /// Why the next page failed (small retry row; the list stays visible).
  final Failure? loadMoreFailure;

  bool get hasMore => page < totalPages;

  bool get isEmpty => status == ServicesStatus.success && services.isEmpty;

  ServicesState copyWith({
    ServicesStatus? status,
    ServiceFilter? filter,
    List<Service>? services,
    int? page,
    int? totalPages,
    int? total,
    bool? isLoadingMore,
    Failure? Function()? failure,
    Failure? Function()? loadMoreFailure,
  }) {
    return ServicesState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      services: services ?? this.services,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      failure: failure != null ? failure() : this.failure,
      loadMoreFailure: loadMoreFailure != null
          ? loadMoreFailure()
          : this.loadMoreFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    filter,
    services,
    page,
    totalPages,
    total,
    isLoadingMore,
    failure,
    loadMoreFailure,
  ];
}
