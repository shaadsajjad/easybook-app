import 'package:dio/dio.dart';
import 'package:easybook_app/core/config/app_config.dart';
import 'package:easybook_app/core/network/auth_interceptor.dart';
import 'package:easybook_app/core/network/dio_client.dart';
import 'package:easybook_app/core/network/session_expiry_notifier.dart';
import 'package:easybook_app/core/storage/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

/// The app's service locator.
final GetIt getIt = GetIt.instance;

/// Registers everything the app needs, grouped by feature.
void configureDependencies(AppConfig config) {
  _registerCore(config);
  // Features (auth, services, appointments, profile, ai) are added in
  // their own steps.
}

void _registerCore(AppConfig config) {
  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<TokenStorage>(() => TokenStorage(getIt()))
    ..registerLazySingleton<SessionExpiryNotifier>(SessionExpiryNotifier.new)
    ..registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(tokenStorage: getIt(), sessionExpiry: getIt()),
    )
    ..registerLazySingleton<Dio>(
      () => createDioClient(config: getIt(), authInterceptor: getIt()),
    );
}
