import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/domain/usecases/create_appointment.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_cubit.dart';
import 'package:easybook_app/features/services/domain/entities/availability.dart';
import 'package:easybook_app/features/services/domain/usecases/get_availability.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/booking_fixtures.dart';

class _MockGetAvailability extends Mock implements GetAvailability;

class _MockCreateAppointment extends Mock implements CreateAppointment;

const _serviceId = '5e000000-0000-4000-8000-000000000001';
final _now = DateTime(2026, 11, 17, 10, 30);
final _today = DateTime(2026, 11, 17);
final _tomorrow = DateTime(2026, 11, 18);

void main() {
  late _MockGetAvailability getAvailability;
  late _MockCreateAppointment createAppointment;

  setUpAll(() {
    registerFallbackValue(
      GetAvailabilityParams(serviceId: _serviceId, day: _today),
    );
    registerFallbackValue(
      const CreateAppointmentParams(serviceId: _serviceId, startTime: ''),
    );
  });

  setUp(() {
    getAvailability = _MockGetAvailability();
    createAppointment = _MockCreateAppointment();
    when(() => getAvailability(any()))
        .thenAnswer((_) async => Right(tAvailability));
  });

  BookingCubit buildCubit() => BookingCubit(
    getAvailability: getAvailability,
    createAppointment: createAppointment,
    clock: () => _now,
  );

  final loaded = BookingState(
    firstDay: _today,
    selectedDay: _today,
    slotsStatus: SlotsStatus.success,
    availability: tAvailability,
  );

  test('starts on today and offers the next days', () {
    final state = buildCubit().state;
    expect(state.selectedDay, _today);
    expect(state.days, hasLength(AppConstants.bookingDaysAhead));
    expect(state.days.first, _today);
    expect(state.days[1], _tomorrow);
  });

  blocTest<BookingCubit, BookingState>(
    'start loads the slots of today',
    build: buildCubit,
    act: (cubit) => cubit.start(_serviceId),
    expect: () => [
      BookingState(
        firstDay: _today,
        selectedDay: _today,
        slotsStatus: SlotsStatus.loading,
      ),
      loaded,
    ],
    verify: (_) => verify(
      () => getAvailability(
        GetAvailabilityParams(serviceId: _serviceId, day: _today),
      ),
    ).called(1),
  );

  blocTest<BookingCubit, BookingState>(
    'shows a failure when slots cannot load',
    setUp: () =>
        when(() => getAvailability(any()))
            .thenAnswer((_) async => const Left(NetworkFailure())),
    build: buildCubit,
    act: (cubit) => cubit.start(_serviceId),
    skip: 1,
    expect: () => [
      BookingState(
        firstDay: _today,
        selectedDay: _today,
        slotsStatus: SlotsStatus.failure,
        slotsFailure: const NetworkFailure(),
      ),
    ],
  );

  blocTest<BookingCubit, BookingState>(
    'picking another day clears the time and loads that day',
    build: buildCubit,
    act: (cubit) async {
      await cubit.start(_serviceId);
      cubit.selectSlot(tSlot(3));
      await cubit.selectDay(_tomorrow);
    },
    verify: (cubit) {
      expect(cubit.state.selectedDay, _tomorrow);
      expect(cubit.state.selectedSlot, isNull);
      verify(
        () => getAvailability(
          GetAvailabilityParams(serviceId: _serviceId, day: _tomorrow),
        ),
      ).called(1);
    },
  );

  blocTest<BookingCubit, BookingState>(
    'picking the same day again does nothing',
    build: buildCubit,
    act: (cubit) async {
      await cubit.start(_serviceId);
      await cubit.selectDay(_today);
    },
    verify: (_) => verify(() => getAvailability(any())).called(1),
  );

  test('only the latest day is shown when answers arrive late', () async {
    final slowToday = Completer<Either<Failure, Availability>>();
    when(
      () => getAvailability(
        GetAvailabilityParams(serviceId: _serviceId, day: _today),
      ),
    ).thenAnswer((_) => slowToday.future);
    final tomorrowSlots = Availability(
      serviceId: _serviceId,
      date: '2026-11-18',
      slots: [tSlot(6)],
    );
    when(
      () => getAvailability(
        GetAvailabilityParams(serviceId: _serviceId, day: _tomorrow),
      ),
    ).thenAnswer((_) async => Right(tomorrowSlots));

    final cubit = buildCubit();
    unawaited(cubit.start(_serviceId));
    await cubit.selectDay(_tomorrow);
    slowToday.complete(Right(tAvailability));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.availability, tomorrowSlots);
    await cubit.close();
  });

  blocTest<BookingCubit, BookingState>(
    'an unavailable slot cannot be selected',
    seed: () => loaded,
    build: buildCubit,
    act: (cubit) => cubit.selectSlot(tSlot(4, available: false)),
    expect: () => <BookingState>[],
  );

  blocTest<BookingCubit, BookingState>(
    'books the selected slot with its exact start time',
    setUp: () =>
        when(() => createAppointment(any()))
            .thenAnswer((_) async => Right(tAppointment)),
    build: buildCubit,
    act: (cubit) async {
      await cubit.start(_serviceId);
      cubit.selectSlot(tSlot(3));
      await cubit.submit(notes: 'Hi');
    },
    verify: (cubit) {
      expect(cubit.state.submitStatus, SubmitStatus.success);
      expect(cubit.state.appointment, tAppointment);
      verify(
        () => createAppointment(
          const CreateAppointmentParams(
            serviceId: _serviceId,
            startTime: '2026-11-20T03:00:00.000Z',
            notes: 'Hi',
          ),
        ),
      ).called(1);
    },
  );

  blocTest<BookingCubit, BookingState>(
    'does nothing without a selected slot',
    seed: () => loaded,
    build: buildCubit,
    act: (cubit) => cubit.submit(),
    expect: () => <BookingState>[],
  );

  blocTest<BookingCubit, BookingState>(
    'ignores a second tap while booking',
    seed: () => loaded.copyWith(
      selectedSlot: () => tSlot(3),
      submitStatus: SubmitStatus.submitting,
    ),
    build: buildCubit,
    act: (cubit) => cubit.submit(),
    expect: () => <BookingState>[],
    verify: (_) => verifyNever(() => createAppointment(any())),
  );

  blocTest<BookingCubit, BookingState>(
    'on 409 it explains, clears the slot and reloads availability',
    setUp: () => when(() => createAppointment(any())).thenAnswer(
      (_) async =>
          const Left(ConflictFailure('This time slot is already booked.')),
    ),
    build: buildCubit,
    act: (cubit) async {
      await cubit.start(_serviceId);
      cubit.selectSlot(tSlot(3));
      await cubit.submit();
    },
    verify: (cubit) {
      expect(cubit.state.submitStatus, SubmitStatus.failure);
      expect(
        cubit.state.submitFailure,
        const ConflictFailure('This time slot is already booked.'),
      );
      expect(cubit.state.selectedSlot, isNull);
      expect(cubit.state.slotsStatus, SlotsStatus.success);
      // Once on start, once after the conflict.
      verify(() => getAvailability(any())).called(2);
    },
  );

  blocTest<BookingCubit, BookingState>(
    'on a network error it keeps the slot so the user can retry',
    setUp: () =>
        when(() => createAppointment(any()))
            .thenAnswer((_) async => const Left(NetworkFailure())),
    build: buildCubit,
    act: (cubit) async {
      await cubit.start(_serviceId);
      cubit.selectSlot(tSlot(3));
      await cubit.submit();
    },
    verify: (cubit) {
      expect(cubit.state.submitStatus, SubmitStatus.failure);
      expect(cubit.state.selectedSlot, tSlot(3));
      verify(() => getAvailability(any())).called(1);
    },
  );
}
