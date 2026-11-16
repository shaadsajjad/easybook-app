import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/network/api_envelope.dart';
import 'package:easybook_app/features/auth/data/models/auth_result_model.dart';
import 'package:easybook_app/features/auth/data/models/user_model.dart';

/// Auth API calls. Only talks to Dio; errors are thrown as they come and
/// turned into failures by the repository.
class AuthRemoteDataSource {
  const new(this._dio);

  final Dio _dio;

  Future<AuthResultModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Object?>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthResultModel.fromJson(ApiEnvelope.dataAsMap(response.data));
  }

  Future<AuthResultModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Object?>(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    return AuthResultModel.fromJson(ApiEnvelope.dataAsMap(response.data));
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get<Object?>(ApiEndpoints.me);
    return UserModel.fromJson(ApiEnvelope.dataAsMap(response.data));
  }

  Future<void> checkHealth() async {
    await _dio.get<Object?>(ApiEndpoints.health);
  }
}
