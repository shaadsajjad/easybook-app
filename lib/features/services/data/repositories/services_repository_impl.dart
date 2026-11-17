import 'package:easybook_app/core/cache/memory_cache.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/network/request_guard.dart';
import 'package:easybook_app/features/services/data/datasources/services_remote_data_source.dart';
import 'package:easybook_app/features/services/domain/entities/availability.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/domain/entities/service_filter.dart';
import 'package:easybook_app/features/services/domain/entities/services_page.dart';
import 'package:easybook_app/features/services/domain/repositories/services_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Services from the API, with an in-memory cache for the read-only lists
/// (categories, featured, list pages, detail). Only successful answers are
/// cached, so a failed call is simply retried next time. Availability is
/// always fetched fresh.
///
/// Registered as a singleton, so the cache lives for the app session.
class ServicesRepositoryImpl implements ServicesRepository {
  /// [now] lets tests move time forward to check expiry.
  new(this._remote, {DateTime Function()? now})
    : _categories = MemoryCache(ttl: AppConstants.categoriesCacheTtl, now: now),
      _featured = MemoryCache(ttl: AppConstants.servicesCacheTtl, now: now),
      _pages = MemoryCache(ttl: AppConstants.servicesCacheTtl, now: now),
      _details = MemoryCache(ttl: AppConstants.servicesCacheTtl, now: now);

  final ServicesRemoteDataSource _remote;

  // Single-value caches use a fixed key.
  static const _only = 0;
  final MemoryCache<int, List<String>> _categories;
  final MemoryCache<int, List<Service>> _featured;
  final MemoryCache<(ServiceFilter, int), ServicesPage> _pages;
  final MemoryCache<String, Service> _details;

  @override
  Future<Either<Failure, ServicesPage>> getServices({
    required ServiceFilter filter,
    required int page,
    bool forceRefresh = false,
  }) {
    // A refresh reloads page 1, so every cached page is now outdated.
    if (forceRefresh) _pages.clear();
    return _cached(_pages, (filter, page), () async {
      final (services, meta) = await _remote.getServices(
        filter: filter,
        page: page,
      );
      return ServicesPage(
        services: services.map((model) => model.toEntity()).toList(),
        page: meta.page,
        totalPages: meta.totalPages,
        total: meta.total,
      );
    });
  }

  @override
  Future<Either<Failure, List<Service>>> getFeaturedServices({
    bool forceRefresh = false,
  }) {
    if (forceRefresh) _featured.clear();
    return _cached(_featured, _only, () async {
      final (services, _) = await _remote.getServices(
        filter: const ServiceFilter(),
        page: 1,
        featuredOnly: true,
      );
      return services.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<String>>> getCategories({
    bool forceRefresh = false,
  }) {
    if (forceRefresh) _categories.clear();
    return _cached(_categories, _only, _remote.getCategories);
  }

  @override
  Future<Either<Failure, Service>> getServiceById(
    String id, {
    bool forceRefresh = false,
  }) {
    if (forceRefresh) _details.remove(id);
    return _cached(_details, id, () async {
      final model = await _remote.getServiceById(id);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Availability>> getAvailability({
    required String serviceId,
    required String date,
  }) {
    return guardRequest(() async {
      final model = await _remote.getAvailability(
        serviceId: serviceId,
        date: date,
      );
      return model.toEntity();
    });
  }

  /// Returns the cached value for [key] if it is still fresh; otherwise
  /// calls the API (through [guardRequest]) and caches a successful answer.
  Future<Either<Failure, V>> _cached<K, V>(
    MemoryCache<K, V> cache,
    K key,
    Future<V> Function() fetch,
  ) async {
    final cached = cache.get(key);
    if (cached != null) return Right(cached);
    final result = await guardRequest(fetch);
    result.fold((_) {}, (value) => cache.set(key, value));
    return result;
  }
}
