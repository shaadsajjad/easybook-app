import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/network/api_envelope.dart';
import 'package:easybook_app/features/appointments/data/models/appointment_model.dart';
import 'package:easybook_app/features/appointments/domain/entities/bookings_tab.dart';

/// Appointment API calls (all need the token, added by AuthInterceptor).
class AppointmentsRemoteDataSource {
  const new(this._dio);

  final Dio _dio;

  Future<AppointmentModel> createAppointment({
    required String serviceId,
    required String startTime,
    String? notes,
  }) async {
    final response = await _dio.post<Object?>(
      ApiEndpoints.appointments,
      data: {'serviceId': serviceId, 'startTime': startTime, 'notes': ?notes},
    );
    return AppointmentModel.fromJson(ApiEnvelope.dataAsMap(response.data));
  }

  Future<List<AppointmentModel>> getAppointments(BookingsTab tab) async {
    final response = await _dio.get<Object?>(
      ApiEndpoints.appointments,
      queryParameters: {'type': tab.name},
    );
    return ApiEnvelope.dataAsList(response.data)
        .map(AppointmentModel.fromJson)
        .toList();
  }

  Future<AppointmentModel> getAppointmentById(String id) async {
    final response = await _dio.get<Object?>(ApiEndpoints.appointmentById(id));
    return AppointmentModel.fromJson(ApiEnvelope.dataAsMap(response.data));
  }

  Future<AppointmentModel> cancelAppointment(String id) async {
    final response = await _dio.patch<Object?>(
      ApiEndpoints.cancelAppointment(id),
    );
    return AppointmentModel.fromJson(ApiEnvelope.dataAsMap(response.data));
  }
}
