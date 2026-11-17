import 'package:dio/dio.dart';
import 'package:easybook_app/core/config/app_config.dart';
import 'package:easybook_app/core/network/auth_interceptor.dart';
import 'package:easybook_app/core/network/dio_client.dart';
import 'package:easybook_app/core/network/session_expiry_notifier.dart';
import 'package:easybook_app/core/storage/token_storage.dart';
import 'package:easybook_app/features/ai_assistant/data/datasources/chat_remote_data_source.dart';
import 'package:easybook_app/features/ai_assistant/data/repositories/chat_repository_impl.dart';
import 'package:easybook_app/features/ai_assistant/domain/repositories/chat_repository.dart';
import 'package:easybook_app/features/ai_assistant/domain/usecases/send_chat_message.dart';
import 'package:easybook_app/features/ai_assistant/presentation/bloc/chat_bloc.dart';
import 'package:easybook_app/features/appointments/data/datasources/appointments_remote_data_source.dart';
import 'package:easybook_app/features/appointments/data/repositories/appointments_repository_impl.dart';
import 'package:easybook_app/features/appointments/domain/repositories/appointments_repository.dart';
import 'package:easybook_app/features/appointments/domain/usecases/cancel_appointment.dart';
import 'package:easybook_app/features/appointments/domain/usecases/create_appointment.dart';
import 'package:easybook_app/features/appointments/domain/usecases/get_appointment_by_id.dart';
import 'package:easybook_app/features/appointments/domain/usecases/get_appointments.dart';
import 'package:easybook_app/features/appointments/domain/usecases/watch_appointment_changes.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_cubit.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_detail_cubit.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/my_bookings_cubit.dart';
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
import 'package:easybook_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:easybook_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:easybook_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:easybook_app/features/profile/domain/usecases/change_password.dart';
import 'package:easybook_app/features/profile/domain/usecases/update_profile.dart';
import 'package:easybook_app/features/profile/presentation/bloc/change_password_cubit.dart';
import 'package:easybook_app/features/profile/presentation/bloc/edit_profile_cubit.dart';
import 'package:easybook_app/features/services/data/datasources/services_remote_data_source.dart';
import 'package:easybook_app/features/services/data/repositories/services_repository_impl.dart';
import 'package:easybook_app/features/services/domain/repositories/services_repository.dart';
import 'package:easybook_app/features/services/domain/usecases/get_availability.dart';
import 'package:easybook_app/features/services/domain/usecases/get_categories.dart';
import 'package:easybook_app/features/services/domain/usecases/get_featured_services.dart';
import 'package:easybook_app/features/services/domain/usecases/get_service_by_id.dart';
import 'package:easybook_app/features/services/domain/usecases/get_services.dart';
import 'package:easybook_app/features/services/presentation/bloc/categories_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/featured_services_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/service_detail_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/services_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

/// The app's service locator.
final GetIt getIt = GetIt.instance;

/// Registers everything the app needs, grouped by feature.
void configureDependencies(AppConfig config) {
  _registerCore(config);
  _registerAuth();
  _registerServices();
  _registerAppointments();
  _registerProfile();
  _registerAssistant();
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

void _registerServices() {
  getIt
    ..registerLazySingleton<ServicesRemoteDataSource>(
      () => ServicesRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<ServicesRepository>(
      () => ServicesRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetServices(getIt()))
    ..registerLazySingleton(() => GetFeaturedServices(getIt()))
    ..registerLazySingleton(() => GetCategories(getIt()))
    ..registerLazySingleton(() => GetServiceById(getIt()))
    ..registerLazySingleton(() => GetAvailability(getIt()))
    ..registerFactory(() => ServicesBloc(getServices: getIt()))
    ..registerFactory(() => FeaturedServicesCubit(getFeaturedServices: getIt()))
    ..registerFactory(() => CategoriesCubit(getCategories: getIt()))
    ..registerFactory(() => ServiceDetailCubit(getServiceById: getIt()));
}

void _registerAppointments() {
  getIt
    ..registerLazySingleton<AppointmentsRemoteDataSource>(
      () => AppointmentsRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<AppointmentsRepository>(
      () => AppointmentsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => CreateAppointment(getIt()))
    ..registerLazySingleton(() => GetAppointments(getIt()))
    ..registerLazySingleton(() => GetAppointmentById(getIt()))
    ..registerLazySingleton(() => CancelAppointment(getIt()))
    ..registerLazySingleton(() => WatchAppointmentChanges(getIt()))
    ..registerFactory(
      () => BookingCubit(getAvailability: getIt(), createAppointment: getIt()),
    )
    ..registerFactory(
      () => MyBookingsCubit(
        getAppointments: getIt(),
        watchAppointmentChanges: getIt(),
      ),
    )
    ..registerFactory(
      () => BookingDetailCubit(
        getAppointmentById: getIt(),
        cancelAppointment: getIt(),
      ),
    );
}

void _registerProfile() {
  getIt
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => UpdateProfile(getIt()))
    ..registerLazySingleton(() => ChangePassword(getIt()))
    ..registerFactory(() => EditProfileCubit(updateProfile: getIt()))
    ..registerFactory(() => ChangePasswordCubit(changePassword: getIt()));
}

void _registerAssistant() {
  getIt
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(getIt()))
    ..registerLazySingleton(() => SendChatMessage(getIt()))
    ..registerFactory(() => ChatBloc(sendChatMessage: getIt()));
}
