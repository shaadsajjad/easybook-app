import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment_status.dart';
import 'package:easybook_app/features/appointments/domain/entities/bookings_tab.dart';
import 'package:easybook_app/features/appointments/domain/usecases/get_appointments.dart';
import 'package:easybook_app/features/appointments/domain/usecases/watch_appointment_changes.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/my_bookings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/booking_fixtures.dart';

class _MockGetAppointments extends Mock implements GetAppointments;

class _MockWatchChanges extends Mock implements WatchAppointmentChanges;

void main() {
  late _MockGetAppointments getAppointments;
  late _MockWatchChanges watchChanges;
  late StreamController<void> changes;

  final completed = tAppointmentWith(AppointmentStatus.completed);

  setUp(() {
    getAppointments = _MockGetAppointments();
    watchChanges = _MockWatchChanges();
    changes = StreamController<void>.broadcast();
    when(() => watchChanges()).thenAnswer((_) => changes.stream);
    when(() => getAppointments(BookingsTab.upcoming))
        .thenAnswer((_) async => Right([tAppointment]));
    when(() => getAppointments(BookingsTab.past))
        .thenAnswer((_) async => Right([completed]));
  });

  tearDown(() => changes.close());

  MyBookingsCubit build() => MyBookingsCubit(
    getAppointments: getAppointments,
    watchAppointmentChanges: watchChanges,
  );

  final loaded = MyBookingsState(
    upcoming: BookingsListState(
      status: BookingsStatus.success,
      appointments: [tAppointment],
    ),
    past: BookingsListState(
      status: BookingsStatus.success,
      appointments: [completed],
    ),
  );

  blocTest<MyBookingsCubit, MyBookingsState>(
    'loadAll fills both tabs',
    build: build,
    act: (cubit) => cubit.loadAll(),
    verify: (cubit) => expect(cubit.state, loaded),
  );

  blocTest<MyBookingsCubit, MyBookingsState>(
    'a failing tab shows its own error and leaves the other one alone',
    setUp: () =>
        when(() => getAppointments(BookingsTab.past))
            .thenAnswer((_) async => const Left(NetworkFailure())),
    build: build,
    act: (cubit) => cubit.loadAll(),
    verify: (cubit) {
      expect(cubit.state.upcoming, loaded.upcoming);
      expect(
        cubit.state.past,
        const BookingsListState(
          status: BookingsStatus.failure,
          failure: NetworkFailure(),
        ),
      );
    },
  );

  blocTest<MyBookingsCubit, MyBookingsState>(
    'keeps the cards on screen while refreshing a tab',
    seed: () => loaded,
    build: build,
    act: (cubit) => cubit.load(BookingsTab.upcoming),
    expect: () => [
      loaded.withTab(
        BookingsTab.upcoming,
        BookingsListState(
          status: BookingsStatus.loading,
          appointments: [tAppointment],
        ),
      ),
      loaded,
    ],
  );

  blocTest<MyBookingsCubit, MyBookingsState>(
    'an empty tab is a success with no bookings',
    setUp: () =>
        when(() => getAppointments(BookingsTab.upcoming))
            .thenAnswer((_) async => const Right([])),
    build: build,
    act: (cubit) => cubit.load(BookingsTab.upcoming),
    verify: (cubit) => expect(cubit.state.upcoming.isEmpty, isTrue),
  );

  blocTest<MyBookingsCubit, MyBookingsState>(
    'reloads both tabs when a booking is created or cancelled',
    build: build,
    act: (_) async {
      changes.add(null);
      await Future<void>.delayed(Duration.zero);
    },
    verify: (cubit) {
      verify(() => getAppointments(BookingsTab.upcoming)).called(1);
      verify(() => getAppointments(BookingsTab.past)).called(1);
      expect(cubit.state, loaded);
    },
  );
}
