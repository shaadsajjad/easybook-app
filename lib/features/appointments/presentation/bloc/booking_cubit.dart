import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/domain/usecases/create_appointment.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_state.dart';
import 'package:easybook_app/features/services/domain/entities/time_slot.dart';
import 'package:easybook_app/features/services/domain/usecases/get_availability.dart';

export 'booking_state.dart';

/// The booking screen: pick a day, see its slots, pick one, book it.
class BookingCubit extends Cubit<BookingState> {
  new({
    required this._getAvailability,
    required this._createAppointment,
    DateTime Function() clock = DateTime.now,
  }) : super(_initialState(clock()));

  final GetAvailability _getAvailability;
  final CreateAppointment _createAppointment;
  late final String _serviceId;

  // Only the newest availability request may update the screen (the user
  // can tap through days faster than the server answers).
  int _requestId = 0;

  static BookingState _initialState(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return BookingState(firstDay: today, selectedDay: today);
  }

  Future<void> start(String serviceId) {
    _serviceId = serviceId;
    return loadSlots();
  }

  Future<void> selectDay(DateTime day) async {
    if (day == state.selectedDay) return;
    emit(state.copyWith(selectedDay: day, selectedSlot: () => null));
    await loadSlots();
  }

  Future<void> loadSlots() async {
    final requestId = ++_requestId;
    emit(
      state.copyWith(
        slotsStatus: SlotsStatus.loading,
        availability: () => null,
        slotsFailure: () => null,
      ),
    );

    final result = await _getAvailability(
      GetAvailabilityParams(serviceId: _serviceId, day: state.selectedDay),
    );
    if (isClosed || requestId != _requestId) return;

    emit(
      result.fold(
        (failure) => state.copyWith(
          slotsStatus: SlotsStatus.failure,
          slotsFailure: () => failure,
        ),
        (availability) => state.copyWith(
          slotsStatus: SlotsStatus.success,
          availability: () => availability,
        ),
      ),
    );
  }

  void selectSlot(TimeSlot slot) {
    if (!slot.available || state.isSubmitting) return;
    emit(state.copyWith(selectedSlot: () => slot));
  }

  Future<void> submit({String? notes}) async {
    final slot = state.selectedSlot;
    // The button is disabled in these cases; this also stops double taps.
    if (slot == null || state.isSubmitting) return;

    emit(
      state.copyWith(
        submitStatus: SubmitStatus.submitting,
        submitFailure: () => null,
      ),
    );
    final result = await _createAppointment(
      CreateAppointmentParams(
        serviceId: _serviceId,
        startTime: slot.startTimeValue,
        notes: notes,
      ),
    );
    if (isClosed) return;

    switch (result.getLeft().toNullable()) {
      case null:
        emit(
          state.copyWith(
            submitStatus: SubmitStatus.success,
            appointment: () => result.getRight().toNullable(),
          ),
        );
      case final Failure failure
          when failure is ConflictFailure || failure is ValidationFailure:
        // Someone else took the slot (409), or it is no longer bookable
        // (422, e.g. it just started): explain, clear it, show fresh slots.
        emit(
          state.copyWith(
            submitStatus: SubmitStatus.failure,
            submitFailure: () => failure,
            selectedSlot: () => null,
          ),
        );
        await loadSlots();
      case final Failure failure:
        // Network or server trouble: keep the choice so the user can retry.
        emit(
          state.copyWith(
            submitStatus: SubmitStatus.failure,
            submitFailure: () => failure,
          ),
        );
    }
  }
}
