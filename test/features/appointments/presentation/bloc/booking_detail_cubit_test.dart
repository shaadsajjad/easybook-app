import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment_status.dart';
import 'package:easybook_app/features/appointments/domain/usecases/cancel_appointment.dart';
import 'package:easybook_app/features/appointments/domain/usecases/get_appointment_by_id.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_detail_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/booking_fixtures.dart';

class _MockGetById extends Mock implements GetAppointmentById;

class _MockCancel extends Mock implements CancelAppointment;

void main() {
  late _MockGetById getById;
  late _MockCancel cancel;

  final cancelled = tAppointmentWith(AppointmentStatus.cancelled);
  final confirmed = tAppointmentWith(AppointmentStatus.confirmed);

  setUp(() {
    getById = _MockGetById();
    cancel = _MockCancel();
    when(() => getById(any())).thenAnswer((_) async => Right(tAppointment));
  });

  BookingDetailCubit build() => BookingDetailCubit(
    getAppointmentById: getById,
    cancelAppointment: cancel,
  );

  final shown = BookingDetailState(
    status: BookingDetailStatus.success,
    appointment: tAppointment,
  );

  group('load', () {
    blocTest<BookingDetailCubit, BookingDetailState>(
      'loads the booking by id',
      build: build,
      act: (cubit) => cubit.load(tAppointment.id),
      expect: () => [
        const BookingDetailState(status: BookingDetailStatus.loading),
        shown,
      ],
    );

    blocTest<BookingDetailCubit, BookingDetailState>(
      'shows the tapped card at once',
      build: build,
      act: (cubit) => cubit.load(tAppointment.id, initial: tAppointment),
      expect: () => [shown],
    );

    blocTest<BookingDetailCubit, BookingDetailState>(
      'shows not found for an unknown or foreign booking',
      setUp: () => when(() => getById(any())).thenAnswer(
        (_) async => const Left(NotFoundFailure('Appointment not found')),
      ),
      build: build,
      act: (cubit) => cubit.load('x', initial: tAppointment),
      expect: () => [
        shown,
        const BookingDetailState(
          status: BookingDetailStatus.failure,
          failure: NotFoundFailure('Appointment not found'),
        ),
      ],
    );
  });

  group('cancel', () {
    blocTest<BookingDetailCubit, BookingDetailState>(
      'cancels a pending booking and shows it as cancelled',
      setUp: () =>
          when(() => cancel(tAppointment.id))
              .thenAnswer((_) async => Right(cancelled)),
      seed: () => shown,
      build: build,
      act: (cubit) => cubit.cancel(),
      expect: () => [
        shown.copyWith(cancelStatus: CancelStatus.cancelling),
        shown.copyWith(
          appointment: cancelled,
          cancelStatus: CancelStatus.success,
        ),
      ],
    );

    blocTest<BookingDetailCubit, BookingDetailState>(
      'does nothing for a booking that is not pending',
      seed: () => BookingDetailState(
        status: BookingDetailStatus.success,
        appointment: confirmed,
      ),
      build: build,
      act: (cubit) => cubit.cancel(),
      expect: () => <BookingDetailState>[],
      verify: (_) => verifyNever(() => cancel(any())),
    );

    blocTest<BookingDetailCubit, BookingDetailState>(
      'ignores a second tap while cancelling',
      seed: () => shown.copyWith(cancelStatus: CancelStatus.cancelling),
      build: build,
      act: (cubit) => cubit.cancel(),
      expect: () => <BookingDetailState>[],
    );

    blocTest<BookingDetailCubit, BookingDetailState>(
      'on 409 it reports the reason and reloads the real status',
      setUp: () {
        when(() => cancel(any())).thenAnswer(
          (_) async => const Left(
            ConflictFailure(
              'Only pending appointments can be cancelled. '
              'This appointment is confirmed.',
            ),
          ),
        );
        when(() => getById(any())).thenAnswer((_) async => Right(confirmed));
      },
      seed: () => shown,
      build: build,
      act: (cubit) => cubit.cancel(),
      verify: (cubit) {
        expect(cubit.state.appointment, confirmed);
        verify(() => getById(tAppointment.id)).called(1);
      },
      expect: () => [
        shown.copyWith(cancelStatus: CancelStatus.cancelling),
        shown.copyWith(
          cancelStatus: CancelStatus.failure,
          cancelFailure: () => const ConflictFailure(
            'Only pending appointments can be cancelled. '
            'This appointment is confirmed.',
          ),
        ),
        shown,
        BookingDetailState(
          status: BookingDetailStatus.success,
          appointment: confirmed,
        ),
      ],
    );

    blocTest<BookingDetailCubit, BookingDetailState>(
      'keeps the booking as is when the network fails',
      setUp: () =>
          when(() => cancel(any()))
              .thenAnswer((_) async => const Left(NetworkFailure())),
      seed: () => shown,
      build: build,
      act: (cubit) => cubit.cancel(),
      expect: () => [
        shown.copyWith(cancelStatus: CancelStatus.cancelling),
        shown.copyWith(
          cancelStatus: CancelStatus.failure,
          cancelFailure: () => const NetworkFailure(),
        ),
      ],
    );
  });
}
