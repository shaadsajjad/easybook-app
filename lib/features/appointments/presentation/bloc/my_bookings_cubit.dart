import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easybook_app/features/appointments/domain/entities/bookings_tab.dart';
import 'package:easybook_app/features/appointments/domain/usecases/get_appointments.dart';
import 'package:easybook_app/features/appointments/domain/usecases/watch_appointment_changes.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/my_bookings_state.dart';

export 'my_bookings_state.dart';

/// Upcoming and Past lists. Reloads both whenever a booking is created or
/// cancelled anywhere in the app, so the tabs are never stale.
class MyBookingsCubit extends Cubit<MyBookingsState> {
  new({
    required this._getAppointments,
    required WatchAppointmentChanges watchAppointmentChanges,
  }) : super(const MyBookingsState()) {
    _changes = watchAppointmentChanges().listen((_) => unawaited(loadAll()));
  }

  final GetAppointments _getAppointments;
  late final StreamSubscription<void> _changes;

  Future<void> loadAll() =>
      Future.wait([load(BookingsTab.upcoming), load(BookingsTab.past)]);

  Future<void> load(BookingsTab tab) async {
    emit(
      state.withTab(
        tab,
        BookingsListState(
          status: BookingsStatus.loading,
          // Keep the cards on screen while refreshing.
          appointments: state.of(tab).appointments,
        ),
      ),
    );
    final result = await _getAppointments(tab);
    if (isClosed) return;
    emit(
      state.withTab(
        tab,
        result.fold(
          (failure) => BookingsListState(
            status: BookingsStatus.failure,
            failure: failure,
          ),
          (appointments) => BookingsListState(
            status: BookingsStatus.success,
            appointments: appointments,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _changes.cancel();
    await super.close();
  }
}
