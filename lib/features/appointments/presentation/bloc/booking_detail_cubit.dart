import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/domain/usecases/cancel_appointment.dart';
import 'package:easybook_app/features/appointments/domain/usecases/get_appointment_by_id.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

enum BookingDetailStatus { initial, loading, success, failure }

enum CancelStatus { idle, cancelling, success, failure }

class BookingDetailState extends Equatable {
  const new({
    this.status = BookingDetailStatus.initial,
    this.appointment,
    this.failure,
    this.cancelStatus = CancelStatus.idle,
    this.cancelFailure,
  });

  final BookingDetailStatus status;
  final Appointment? appointment;
  final Failure? failure;
  final CancelStatus cancelStatus;
  final Failure? cancelFailure;

  bool get isCancelling => cancelStatus == CancelStatus.cancelling;

  BookingDetailState copyWith({
    BookingDetailStatus? status,
    Appointment? appointment,
    CancelStatus? cancelStatus,
    Failure? Function()? cancelFailure,
  }) {
    return BookingDetailState(
      status: status ?? this.status,
      appointment: appointment ?? this.appointment,
      failure: failure,
      cancelStatus: cancelStatus ?? this.cancelStatus,
      cancelFailure: cancelFailure != null
          ? cancelFailure()
          : this.cancelFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    appointment,
    failure,
    cancelStatus,
    cancelFailure,
  ];
}

/// One booking, with the Cancel action.
class BookingDetailCubit extends Cubit<BookingDetailState> {
  new({required this._getAppointmentById, required this._cancelAppointment})
    : super(const BookingDetailState());

  final GetAppointmentById _getAppointmentById;
  final CancelAppointment _cancelAppointment;

  /// [initial] (the tapped card) is shown at once while the fresh copy loads.
  Future<void> load(String id, {Appointment? initial}) async {
    emit(
      initial == null
          ? const BookingDetailState(status: BookingDetailStatus.loading)
          : BookingDetailState(
              status: BookingDetailStatus.success,
              appointment: initial,
            ),
    );
    final result = await _getAppointmentById(id);
    if (isClosed) return;
    final shown = state.appointment;
    emit(
      result.fold(
        (failure) => shown != null && failure is! NotFoundFailure
            ? state
            : BookingDetailState(
                status: BookingDetailStatus.failure,
                failure: failure,
              ),
        (appointment) => BookingDetailState(
          status: BookingDetailStatus.success,
          appointment: appointment,
        ),
      ),
    );
  }

  Future<void> cancel() async {
    final appointment = state.appointment;
    if (appointment == null || !appointment.canCancel || state.isCancelling) {
      return;
    }
    emit(
      state.copyWith(
        cancelStatus: CancelStatus.cancelling,
        cancelFailure: () => null,
      ),
    );
    final result = await _cancelAppointment(appointment.id);
    if (isClosed) return;

    switch (result) {
      case Right(value: final cancelled):
        emit(
          state.copyWith(
            appointment: cancelled,
            cancelStatus: CancelStatus.success,
          ),
        );
      case Left(value: final failure):
        emit(
          state.copyWith(
            cancelStatus: CancelStatus.failure,
            cancelFailure: () => failure,
          ),
        );
        // 409: the status changed on the server (for example it was just
        // confirmed). Show the real status.
        if (failure is ConflictFailure) {
          await load(appointment.id, initial: appointment);
        }
    }
  }
}
