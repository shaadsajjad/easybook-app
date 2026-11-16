import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/utils/date_formatter.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_cubit.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/appointment_ticket.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/booking_summary_bar.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/slot_grid.dart';
import 'package:easybook_app/features/services/domain/entities/availability.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/booking_fixtures.dart';
import '../../../../helpers/helpers.dart';

class _MockBookingCubit extends MockCubit<BookingState> implements BookingCubit;

void main() {
  late _MockBookingCubit cubit;
  final today = DateTime(2026, 11, 20);

  setUpAll(initializeDateFormatting);

  setUp(() {
    cubit = _MockBookingCubit();
    when(() => cubit.selectSlot(any())).thenReturn(null);
  });

  setUpAll(() => registerFallbackValue(tSlot(3)));

  Future<void> pump(WidgetTester tester, BookingState state, Widget child) {
    when(() => cubit.state).thenReturn(state);
    return tester.pumpApp(
      BlocProvider<BookingCubit>.value(
        value: cubit,
        child: SingleChildScrollView(child: child),
      ),
    );
  }

  final loaded = BookingState(
    firstDay: today,
    selectedDay: today,
    slotsStatus: SlotsStatus.success,
    availability: tAvailability,
  );

  testWidgets('SlotGrid selects available slots and ignores the rest', (
    tester,
  ) async {
    await pump(tester, loaded, const SlotGrid());

    final available = tSlot(3);
    final taken = tSlot(4, available: false);
    String label(DateTime time) => DateFormatter.time(time, 'en');

    expect(find.byType(InkWell), findsNWidgets(3));
    await tester.tap(find.text(label(available.start)));
    verify(() => cubit.selectSlot(available)).called(1);

    await tester.tap(find.text(label(taken.start)));
    verifyNever(() => cubit.selectSlot(taken));
  });

  testWidgets('SlotGrid shows a message when the day is fully booked', (
    tester,
  ) async {
    await pump(
      tester,
      loaded.copyWith(
        availability: () => Availability(
          serviceId: tAvailability.serviceId,
          date: tAvailability.date,
          slots: [tSlot(4, available: false)],
        ),
      ),
      const SlotGrid(),
    );
    expect(find.text(LocaleKeys.booking_no_slots_title), findsOneWidget);
  });

  testWidgets('the confirm button is disabled until a time is picked', (
    tester,
  ) async {
    var confirms = 0;
    await pump(tester, loaded, BookingSummaryBar(onConfirm: () => confirms++));

    await tester.tap(find.text(LocaleKeys.booking_confirm));
    expect(confirms, 0);
    expect(find.text(LocaleKeys.booking_choose_time_first), findsOneWidget);
  });

  testWidgets('the confirm button books the picked time', (tester) async {
    var confirms = 0;
    await pump(
      tester,
      loaded.copyWith(selectedSlot: () => tSlot(3)),
      BookingSummaryBar(onConfirm: () => confirms++),
    );

    await tester.tap(find.text(LocaleKeys.booking_confirm));
    expect(confirms, 1);
  });

  testWidgets('AppointmentTicket shows the booking details', (tester) async {
    await tester.pumpApp(
      SingleChildScrollView(
        child: AppointmentTicket(appointment: tAppointment),
      ),
    );

    expect(find.text('Classic Haircut'), findsOneWidget);
    expect(find.text('৳500'), findsOneWidget);
    expect(find.text(LocaleKeys.appointments_status_pending), findsOneWidget);
    expect(find.text('Short on the sides, please.'), findsOneWidget);
  });
}
