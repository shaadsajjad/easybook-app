import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/theme/app_theme.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/features/ai_assistant/presentation/bloc/chat_bloc.dart';
import 'package:easybook_app/features/ai_assistant/presentation/pages/assistant_page.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment_status.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_cubit.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_detail_cubit.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/my_bookings_cubit.dart';
import 'package:easybook_app/features/appointments/presentation/pages/booking_confirmation_page.dart';
import 'package:easybook_app/features/appointments/presentation/pages/booking_detail_page.dart';
import 'package:easybook_app/features/appointments/presentation/pages/booking_page.dart';
import 'package:easybook_app/features/appointments/presentation/pages/my_bookings_page.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/auth/presentation/bloc/login_cubit.dart';
import 'package:easybook_app/features/auth/presentation/bloc/register_cubit.dart';
import 'package:easybook_app/features/auth/presentation/bloc/splash_cubit.dart';
import 'package:easybook_app/features/auth/presentation/pages/login_page.dart';
import 'package:easybook_app/features/auth/presentation/pages/register_page.dart';
import 'package:easybook_app/features/auth/presentation/pages/splash_page.dart';
import 'package:easybook_app/features/profile/presentation/bloc/change_password_cubit.dart';
import 'package:easybook_app/features/profile/presentation/bloc/edit_profile_cubit.dart';
import 'package:easybook_app/features/profile/presentation/pages/change_password_page.dart';
import 'package:easybook_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:easybook_app/features/profile/presentation/pages/profile_page.dart';
import 'package:easybook_app/features/services/presentation/bloc/categories_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/featured_services_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/service_detail_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/services_bloc.dart';
import 'package:easybook_app/features/services/presentation/pages/home_page.dart';
import 'package:easybook_app/features/services/presentation/pages/service_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/auth_fixtures.dart';
import '../helpers/booking_fixtures.dart';
import '../helpers/chat_fixtures.dart';
import '../helpers/service_fixtures.dart';
import '../helpers/translations.dart';

class _AuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc;

class _SplashCubit extends MockCubit<SplashState> implements SplashCubit;

class _LoginCubit extends MockCubit<AuthFormState> implements LoginCubit;

class _RegisterCubit extends MockCubit<AuthFormState> implements RegisterCubit;

class _ServicesBloc extends MockBloc<ServicesEvent, ServicesState>
    implements ServicesBloc;

class _FeaturedCubit extends MockCubit<FeaturedServicesState>
    implements FeaturedServicesCubit;

class _CategoriesCubit extends MockCubit<CategoriesState>
    implements CategoriesCubit;

class _DetailCubit extends MockCubit<ServiceDetailState>
    implements ServiceDetailCubit;

class _BookingCubit extends MockCubit<BookingState> implements BookingCubit;

class _MyBookingsCubit extends MockCubit<MyBookingsState>
    implements MyBookingsCubit;

class _BookingDetailCubit extends MockCubit<BookingDetailState>
    implements BookingDetailCubit;

class _EditCubit extends MockCubit<ProfileFormState>
    implements EditProfileCubit;

class _PasswordCubit extends MockCubit<ProfileFormState>
    implements ChangePasswordCubit;

class _ChatBloc extends MockBloc<ChatEvent, ChatState> implements ChatBloc;

/// The worst realistic case: a small phone (iPhone SE size), dark mode and
/// text at 200%. Any overflow makes the test fail.
const Size _smallPhone = Size(320, 568);
const double _largeText = 2;

/// One screen with the blocs it needs, already in a loaded state.
typedef _Screen = ({String name, Widget Function() build});

List<_Screen> _screens() {
  final auth = _AuthBloc();
  when(() => auth.state).thenReturn(AuthState.authenticated(tUser));
  final loggedOut = _AuthBloc();
  when(() => loggedOut.state)
      .thenReturn(const AuthState.unauthenticated(sessionExpired: true));
  final splashAuth = _AuthBloc();
  when(() => splashAuth.state)
      .thenReturn(const AuthState.unknown(failure: NetworkFailure()));

  final splash = _SplashCubit();
  when(() => splash.state).thenReturn(const SplashState(showWakeUpHint: true));
  final login = _LoginCubit();
  when(() => login.state).thenReturn(
    const AuthFormState(
      status: FormStatus.failure,
      failure: UnauthorizedFailure('Invalid email or password'),
    ),
  );
  final register = _RegisterCubit();
  when(() => register.state).thenReturn(const AuthFormState());

  final services = _ServicesBloc();
  when(() => services.state).thenReturn(
    const ServicesState(
      status: ServicesStatus.success,
      services: [tService, tMassage],
      page: 1,
      totalPages: 1,
      total: 2,
    ),
  );
  final featured = _FeaturedCubit();
  when(() => featured.state).thenReturn(
    const FeaturedServicesState(
      status: FeaturedStatus.success,
      services: [tService, tMassage],
    ),
  );
  final categories = _CategoriesCubit();
  when(() => categories.state).thenReturn(
    const CategoriesState(
      status: CategoriesStatus.success,
      categories: ['Hair & Beauty', 'Health', 'Home Services', 'Wellness'],
    ),
  );
  final detail = _DetailCubit();
  when(() => detail.state).thenReturn(
    const ServiceDetailState(
      status: ServiceDetailStatus.success,
      service: tService,
    ),
  );
  final today = DateTime(2026, 11, 20);
  final booking = _BookingCubit();
  when(() => booking.state).thenReturn(
    BookingState(
      firstDay: today,
      selectedDay: today,
      slotsStatus: SlotsStatus.success,
      availability: tAvailability,
      selectedSlot: tSlot(3),
    ),
  );
  final myBookings = _MyBookingsCubit();
  when(() => myBookings.state).thenReturn(
    MyBookingsState(
      upcoming: BookingsListState(
        status: BookingsStatus.success,
        appointments: [tAppointment],
      ),
      past: BookingsListState(
        status: BookingsStatus.success,
        appointments: [tAppointmentWith(AppointmentStatus.completed)],
      ),
    ),
  );
  final bookingDetail = _BookingDetailCubit();
  when(() => bookingDetail.state).thenReturn(
    BookingDetailState(
      status: BookingDetailStatus.success,
      appointment: tAppointment,
    ),
  );
  final edit = _EditCubit();
  when(() => edit.state).thenReturn(const ProfileFormState());
  final password = _PasswordCubit();
  when(() => password.state).thenReturn(const ProfileFormState());
  final chat = _ChatBloc();
  when(() => chat.state).thenReturn(
    const ChatState(
      messages: [tQuestion, tAssistantReply],
      failure: ServiceUnavailableFailure(
        'The assistant is busy right now. Please try again in a minute.',
      ),
      failedMessage: 'I have a stiff back.',
    ),
  );

  Widget withAuth(AuthBloc bloc, Widget child) =>
      BlocProvider<AuthBloc>.value(value: bloc, child: child);

  return [
    (
      name: 'splash (connection error)',
      build: () => withAuth(
        splashAuth,
        BlocProvider<SplashCubit>.value(
          value: splash,
          child: const SplashView(),
        ),
      ),
    ),
    (
      name: 'login (expired session, wrong password)',
      build: () => withAuth(
        loggedOut,
        BlocProvider<LoginCubit>.value(value: login, child: const LoginView()),
      ),
    ),
    (
      name: 'register',
      build: () => withAuth(
        loggedOut,
        BlocProvider<RegisterCubit>.value(
          value: register,
          child: const RegisterView(),
        ),
      ),
    ),
    (
      name: 'home',
      build: () => withAuth(
        auth,
        MultiBlocProvider(
          providers: [
            BlocProvider<ServicesBloc>.value(value: services),
            BlocProvider<FeaturedServicesCubit>.value(value: featured),
            BlocProvider<CategoriesCubit>.value(value: categories),
          ],
          child: const HomeView(),
        ),
      ),
    ),
    (
      name: 'service detail',
      build: () => BlocProvider<ServiceDetailCubit>.value(
        value: detail,
        child: const ServiceDetailView(serviceId: 'id'),
      ),
    ),
    (
      name: 'booking',
      build: () => MultiBlocProvider(
        providers: [
          BlocProvider<ServiceDetailCubit>.value(value: detail),
          BlocProvider<BookingCubit>.value(value: booking),
        ],
        child: const BookingView(),
      ),
    ),
    (
      name: 'booking confirmation',
      build: () => BookingConfirmationPage(appointment: tAppointment),
    ),
    (
      name: 'my bookings',
      build: () => BlocProvider<MyBookingsCubit>.value(
        value: myBookings,
        child: const MyBookingsView(),
      ),
    ),
    (
      name: 'booking detail (pending, can cancel)',
      build: () => BlocProvider<BookingDetailCubit>.value(
        value: bookingDetail,
        child: const BookingDetailView(appointmentId: 'id'),
      ),
    ),
    (name: 'profile', build: () => withAuth(auth, const ProfilePage())),
    (
      name: 'edit profile',
      build: () => BlocProvider<EditProfileCubit>.value(
        value: edit,
        child: Scaffold(body: EditProfileForm(user: tUser)),
      ),
    ),
    (
      name: 'change password',
      build: () => BlocProvider<ChangePasswordCubit>.value(
        value: password,
        child: const Scaffold(body: ChangePasswordForm()),
      ),
    ),
    (
      name: 'assistant (conversation with an error)',
      build: () => withAuth(
        auth,
        BlocProvider<ChatBloc>.value(value: chat, child: const AssistantView()),
      ),
    ),
  ];
}

Future<void> _pumpStressed(WidgetTester tester, Widget screen) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = _smallPhone;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(_largeText)),
        child: child!,
      ),
      home: screen,
    ),
  );
  // Animations (shimmer, typing dots) repeat forever, so pump a fixed time.
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUpAll(initializeDateFormatting);

  for (final language in ['en', 'bn']) {
    group('[$language] dark mode, 200% text, small phone', () {
      setUp(() => loadTranslations(language));
      tearDown(unloadTranslations);

      for (final screen in _screens()) {
        testWidgets('${screen.name} has no overflow', (tester) async {
          // Flutter fails the test by itself if anything overflows.
          await _pumpStressed(tester, screen.build());
        });
      }
    });
  }

  group('accessibility', () {
    tearDown(unloadTranslations);

    for (final screen in _screens()) {
      testWidgets('${screen.name}: tap targets and labels', (tester) async {
        loadTranslations('en');
        final semantics = tester.ensureSemantics();
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = const Size(390, 844);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: screen.build()),
        );
        await tester.pump(const Duration(seconds: 1));

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        semantics.dispose();
      });
    }
  });

  group('dark mode text contrast', () {
    tearDown(unloadTranslations);

    for (final screen in _screens()) {
      testWidgets('${screen.name}: text is readable', (tester) async {
        loadTranslations('en');
        final semantics = tester.ensureSemantics();
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = const Size(390, 844);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.dark,
            home: screen.build(),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    }
  });
}
