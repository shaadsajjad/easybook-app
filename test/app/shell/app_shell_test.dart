import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_router.dart';
import 'package:easybook_app/core/router/placeholder_page.dart';
import 'package:easybook_app/core/theme/app_theme.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_fixtures.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc;

void main() {
  testWidgets('a logged-in user lands on Home and can switch tabs', (
    tester,
  ) async {
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
    await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, path);
    }
    expect(find.byType(PlaceholderPage), findsWidgets);
  });
}
