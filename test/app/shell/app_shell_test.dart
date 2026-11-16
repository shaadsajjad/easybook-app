import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_router.dart';
import 'package:easybook_app/core/theme/app_theme.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/my_bookings_cubit.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/services/presentation/bloc/categories_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/featured_services_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/services_bloc.dart';
import 'package:easybook_app/features/services/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_fixtures.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc;

class _MockServicesBloc extends MockBloc<ServicesEvent, ServicesState>
    implements ServicesBloc;

class _MockFeaturedCubit extends MockCubit<FeaturedServicesState>
    implements FeaturedServicesCubit;

class _MockCategoriesCubit extends MockCubit<CategoriesState>
    implements CategoriesCubit;

class _MockMyBookingsCubit extends MockCubit<MyBookingsState>
    implements MyBookingsCubit;

/// Home and My Bookings get their blocs from get_it; register idle mocks.
void _registerHomeMocks() {
  final services = _MockServicesBloc();
  final featured = _MockFeaturedCubit();
  final categories = _MockCategoriesCubit();
  when(() => services.state).thenReturn(const ServicesState());
  when(() => featured.state).thenReturn(const FeaturedServicesState());
  when(featured.load).thenAnswer((_) async {});
  when(() => categories.state).thenReturn(const CategoriesState());
  when(categories.load).thenAnswer((_) async {});
  final bookings = _MockMyBookingsCubit();
  when(() => bookings.state).thenReturn(const MyBookingsState());
  when(bookings.loadAll).thenAnswer((_) async {});
  getIt
    ..registerFactory<MyBookingsCubit>(() => bookings)
    ..registerFactory<ServicesBloc>(() => services)
    ..registerFactory<FeaturedServicesCubit>(() => featured)
    ..registerFactory<CategoriesCubit>(() => categories);
}

void main() {
  testWidgets('a logged-in user lands on Home and can switch tabs', (
    tester,
  ) async {
    _registerHomeMocks();
    addTearDown(getIt.reset);
    final authBloc = _MockAuthBloc();
    when(() => authBloc.state).thenReturn(AuthState.authenticated(tUser));
    final router = createAppRouter(authBloc);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(router.state.matchedLocation, '/home');

    final tabs = {
      LocaleKeys.nav_bookings: '/bookings',
      LocaleKeys.nav_assistant: '/assistant',
      LocaleKeys.nav_profile: '/profile',
      LocaleKeys.nav_home: '/home',
    };
    for (final MapEntry(key: label, value: path) in tabs.entries) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(router.state.matchedLocation, path);
    }
    expect(find.byType(HomePage), findsOneWidget);
  });
}
