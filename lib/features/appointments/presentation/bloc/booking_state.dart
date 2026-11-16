import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/services/domain/entities/availability.dart';
import 'package:easybook_app/features/services/domain/entities/time_slot.dart';
import 'package:equatable/equatable.dart';

enum SlotsStatus { initial, loading, success, failure }

enum SubmitStatus { idle, submitting, success, failure }

class BookingState extends Equatable {
  const new({
    required this.firstDay,
    required this.selectedDay,
    this.slotsStatus = SlotsStatus.initial,
    this.availability,
    this.slotsFailure,
    this.selectedSlot,
    this.submitStatus = SubmitStatus.idle,
    this.submitFailure,
    this.appointment,
  });

  /// Today (date only). The date strip starts here.
  final DateTime firstDay;
  final DateTime selectedDay;

  final SlotsStatus slotsStatus;
  final Availability? availability;
  final Failure? slotsFailure;

  final TimeSlot? selectedSlot;

  final SubmitStatus submitStatus;

  /// Why the last booking attempt failed (shown once as a message).
  final Failure? submitFailure;

  /// The created booking, after a successful submit.
  final Appointment? appointment;

  /// The days the user can pick: today and the next ones.
  List<DateTime> get days => List.generate(
    AppConstants.bookingDaysAhead,
    (index) => DateTime(firstDay.year, firstDay.month, firstDay.day + index),
  );

  bool get isSubmitting => submitStatus == SubmitStatus.submitting;

  BookingState copyWith({
    DateTime? selectedDay,
    SlotsStatus? slotsStatus,
    Availability? Function()? availability,
    Failure? Function()? slotsFailure,
    TimeSlot? Function()? selectedSlot,
    SubmitStatus? submitStatus,
    Failure? Function()? submitFailure,
    Appointment? Function()? appointment,
  }) {
    return BookingState(
      firstDay: firstDay,
      selectedDay: selectedDay ?? this.selectedDay,
      slotsStatus: slotsStatus ?? this.slotsStatus,
      availability: availability != null ? availability() : this.availability,
      slotsFailure: slotsFailure != null ? slotsFailure() : this.slotsFailure,
      selectedSlot: selectedSlot != null ? selectedSlot() : this.selectedSlot,
      submitStatus: submitStatus ?? this.submitStatus,
      submitFailure: submitFailure != null
          ? submitFailure()
          : this.submitFailure,
      appointment: appointment != null ? appointment() : this.appointment,
    );
  }

  @override
  List<Object?> get props => [
    firstDay,
    selectedDay,
    slotsStatus,
    availability,
    slotsFailure,
    selectedSlot,
    submitStatus,
    submitFailure,
    appointment,
  ];
}
