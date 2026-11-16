import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/network/api_envelope.dart';
import 'package:easybook_app/features/services/data/models/availability_model.dart';
import 'package:easybook_app/features/services/data/models/pagination_meta_model.dart';
import 'package:easybook_app/features/services/data/models/service_model.dart';
import 'package:easybook_app/features/services/domain/entities/service_filter.dart';

/// Services API calls (all public, no token needed).
class ServicesRemoteDataSource {
  const new(this._dio);

  final Dio _dio;

  Future<(List<ServiceModel>, PaginationMetaModel)> getServices({
    required ServiceFilter filter,
    required int page,
    bool featuredOnly = false,
  }) async {
    final search = filter.search.trim();
    final response = await _dio.get<Object?>(
      ApiEndpoints.services,
      queryParameters: {
        'page': page,
        'limit': AppConstants.servicesPageSize,
        if (search.isNotEmpty) 'search': search,
        if (filter.category != null) 'category': filter.category,
        if (filter.minPrice != null) 'minPrice': filter.minPrice,
        if (filter.maxPrice != null) 'maxPrice': filter.maxPrice,
        if (featuredOnly) 'featured': 'true',
      },
    );
    final services = ApiEnvelope.dataAsList(response.data)
        .map(ServiceModel.fromJson)
        .toList();
    final meta = PaginationMetaModel.fromJson(ApiEnvelope.meta(response.data));
    return (services, meta);
  }

  Future<List<String>> getCategories() async {
    final response = await _dio.get<Object?>(ApiEndpoints.categories);
    return ApiEnvelope.dataAsStringList(response.data);
  }

  Future<ServiceModel> getServiceById(String id) async {
    final response = await _dio.get<Object?>(ApiEndpoints.serviceById(id));
    return ServiceModel.fromJson(ApiEnvelope.dataAsMap(response.data));
  }

  Future<AvailabilityModel> getAvailability({
    required String serviceId,
    required String date,
  }) async {
    final response = await _dio.get<Object?>(
      ApiEndpoints.availability(serviceId),
      queryParameters: {'date': date},
    );
    return AvailabilityModel.fromJson(ApiEnvelope.dataAsMap(response.data));
  }
}
