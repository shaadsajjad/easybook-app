import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/network/session_expiry_notifier.dart';
import 'package:easybook_app/core/storage/token_storage.dart';

/// Adds the Bearer token to every request and handles 401 in ONE place.
///
/// A 401 from login/register means "wrong email or password" and is passed
/// through untouched. A 401 from any other (protected) route means the
/// session is over: the token is deleted and [SessionExpiryNotifier] fires.
class AuthInterceptor extends Interceptor {
  new({required this._tokenStorage, required this._sessionExpiry});

  final TokenStorage _tokenStorage;
  final SessionExpiryNotifier _sessionExpiry;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isCredentialRoute(options)) {
      final token = await _tokenStorage.read();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    if (isUnauthorized && !_isCredentialRoute(err.requestOptions)) {
      await _tokenStorage.clear();
      _sessionExpiry.notify();
    }
    handler.next(err);
  }

  bool _isCredentialRoute(RequestOptions options) =>
      ApiEndpoints.credentialRoutes.contains(options.path);
}
