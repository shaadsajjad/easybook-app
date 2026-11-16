import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/domain/entities/bookings_tab.dart';
import 'package:equatable/equatable.dart';

enum BookingsStatus { initial, loading, success, failure }

/// One tab's list.
class BookingsListState extends Equatable {
  const new({
    this.status = BookingsStatus.initial,
    this.appointments = const [],
    this.failure,
  });

  final BookingsStatus status;
  final List<Appointment> appointments;
  final Failure? failure;

  bool get isEmpty => status == BookingsStatus.success && appointments.isEmpty;

  @override
  List<Object?> get props => [status, appointments, failure];
}

/// Both tabs of My Bookings.
class MyBookingsState extends Equatable {
  const new({
    this.upcoming = const BookingsListState(),
    this.past = const BookingsListState(),
  });

  final BookingsListState upcoming;
  final BookingsListState past;

  BookingsListState of(BookingsTab tab) => switch (tab) {
    BookingsTab.upcoming => upcoming,
    BookingsTab.past => past,
  };

  MyBookingsState withTab(BookingsTab tab, BookingsListState list) =>
      switch (tab) {
        BookingsTab.upcoming => MyBookingsState(upcoming: list, past: past),
        BookingsTab.past => MyBookingsState(upcoming: upcoming, past: list),
      };

  @override
  List<Object> get props => [upcoming, past];
}
