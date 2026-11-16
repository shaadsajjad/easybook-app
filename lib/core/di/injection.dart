import 'package:dio/dio.dart';
import 'package:easybook_app/core/config/app_config.dart';
import 'package:easybook_app/core/network/auth_interceptor.dart';
import 'package:easybook_app/core/network/dio_client.dart';
import 'package:easybook_app/core/network/session_expiry_notifier.dart';
import 'package:easybook_app/core/storage/token_storage.dart';
import 'package:easybook_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easybook_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:easybook_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:easybook_app/features/auth/domain/usecases/login.dart';
import 'package:easybook_app/features/auth/domain/usecases/logout.dart';
import 'package:easybook_app/features/auth/domain/usecases/register.dart';
import 'package:easybook_app/features/auth/domain/usecases/restore_session.dart';
import 'package:easybook_app/features/auth/domain/usecases/wake_server.dart';
import 'package:easybook_app/features/auth/domain/usecases/watch_session_expired.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/auth/presentation/bloc/login_cubit.dart';
import 'package:easybook_app/features/auth/presentation/bloc/register_cubit.dart';
import 'package:easybook_app/features/auth/presentation/bloc/splash_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

/// The app's service locator.
final GetIt getIt = GetIt.instance;

/// Registers everything the app needs, grouped by feature.
void configureDependencies(AppConfig config) {
  _registerCore(config);
  _registerAuth();
  // Services, appointments, profile and AI are added in their own steps.
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

/// Data sources, repositories and use cases are singletons (stateless).
/// Blocs and cubits are factories: each page gets a fresh one.
void _registerAuth() {
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: getIt(),
        tokenStorage: getIt(),
        sessionExpiry: getIt(),
      ),
    )
    ..registerLazySingleton(() => Login(getIt()))
    ..registerLazySingleton(() => Register(getIt()))
    ..registerLazySingleton(() => RestoreSession(getIt()))
    ..registerLazySingleton(() => Logout(getIt()))
    ..registerLazySingleton(() => WakeServer(getIt()))
    ..registerLazySingleton(() => WatchSessionExpired(getIt()))
    ..registerFactory(
      () => AuthBloc(
        restoreSession: getIt(),
        logout: getIt(),
        watchSessionExpired: getIt(),
      ),
    )
    ..registerFactory(() => SplashCubit(wakeServer: getIt()))
    ..registerFactory(() => LoginCubit(login: getIt()))
    ..registerFactory(() => RegisterCubit(register: getIt()));
}
