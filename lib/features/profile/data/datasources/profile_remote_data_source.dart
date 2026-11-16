import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/network/api_envelope.dart';
import 'package:easybook_app/features/auth/data/models/user_model.dart';

/// Profile API calls (the token is added by AuthInterceptor).
class ProfileRemoteDataSource {
  const new(this._dio);

  final Dio _dio;

  /// `phone: null` is sent on purpose: it clears the phone number.
  Future<UserModel> updateProfile({required String name, String? phone}) async {
    final response = await _dio.patch<Object?>(
      ApiEndpoints.me,
      data: {'name': name, 'phone': phone},
    );
    return UserModel.fromJson(ApiEnvelope.dataAsMap(response.data));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.patch<Object?>(
      ApiEndpoints.changePassword,
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }
}
