import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment_status.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_detail_cubit.dart';
import 'package:easybook_app/features/appointments/presentation/pages/booking_detail_page.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/booking_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/booking_fixtures.dart';
import '../../../../helpers/helpers.dart';

class _MockDetailCubit extends MockCubit<BookingDetailState>
    implements BookingDetailCubit;

void main() {
  setUpAll(initializeDateFormatting);

  testWidgets('BookingCard shows the service, status and price', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpApp(
      BookingCard(
        appointment: tAppointment,
        highlightDate: true,
        onTap: () => taps++,
      ),
    );

    expect(find.text('Classic Haircut'), findsOneWidget);
    expect(find.text(LocaleKeys.appointments_status_pending), findsOneWidget);
    expect(find.text('৳500'), findsOneWidget);
    await tester.tap(find.byType(BookingCard));
    expect(taps, 1);
  });

  group('BookingDetailView', () {
    late _MockDetailCubit cubit;

    setUp(() {
      cubit = _MockDetailCubit();
      when(() => cubit.cancel()).thenAnswer((_) async {});
    });

    Future<void> pump(WidgetTester tester, AppointmentStatus status) {
      when(() => cubit.state).thenReturn(
        BookingDetailState(
          status: BookingDetailStatus.success,
          appointment: tAppointmentWith(status),
        ),
      );
      return tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BookingDetailCubit>.value(
            value: cubit,
            child: const BookingDetailView(appointmentId: 'id'),
          ),
        ),
      );
    }

    testWidgets('a pending booking can be cancelled after confirming', (
      tester,
    ) async {
      await pump(tester, AppointmentStatus.pending);

      final cancelButton = find.text(LocaleKeys.appointments_cancel_button);
      await tester.ensureVisible(cancelButton);
      await tester.tap(cancelButton);
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.text(LocaleKeys.appointments_cancel_confirm_title),
        findsOneWidget,
      );

      await tester.tap(find.text(LocaleKeys.appointments_confirm_cancel));
      await tester.pump(const Duration(milliseconds: 500));
      verify(() => cubit.cancel()).called(1);
    });

    testWidgets('choosing "Keep booking" does not cancel', (tester) async {
      await pump(tester, AppointmentStatus.pending);

      final cancelButton = find.text(LocaleKeys.appointments_cancel_button);
      await tester.ensureVisible(cancelButton);
      await tester.tap(cancelButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text(LocaleKeys.appointments_keep_booking));
      await tester.pump(const Duration(milliseconds: 500));

      verifyNever(() => cubit.cancel());
    });

    testWidgets('a confirmed booking has no cancel button, only a note', (
      tester,
    ) async {
      await pump(tester, AppointmentStatus.confirmed);

      expect(find.text(LocaleKeys.appointments_cancel_button), findsNothing);
      expect(
        find.text(LocaleKeys.appointments_cannot_cancel_note),
        findsOneWidget,
      );
    });

    testWidgets('completed and cancelled bookings show neither', (
      tester,
    ) async {
      for (final status in [
        AppointmentStatus.completed,
        AppointmentStatus.cancelled,
      ]) {
        await pump(tester, status);
        expect(find.text(LocaleKeys.appointments_cancel_button), findsNothing);
        expect(
          find.text(LocaleKeys.appointments_cannot_cancel_note),
          findsNothing,
        );
      }
    });
  });
}
