import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easybook_app/core/config/app_config.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/network/auth_interceptor.dart';

/// Builds the single Dio instance used by every remote data source.
Dio createDioClient({
  required AppConfig config,
  required AuthInterceptor authInterceptor,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.connectTimeout,
      contentType: Headers.jsonContentType,
      headers: {Headers.acceptHeader: Headers.jsonContentType},
    ),
  )..interceptors.add(authInterceptor);

  if (config.enableLogging) {
    // Method, URL and status only: never headers (token) or bodies
    // (passwords, personal data).
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        logPrint: (line) => log(line.toString(), name: 'http'),
      ),
    );
  }
  return dio;
}
