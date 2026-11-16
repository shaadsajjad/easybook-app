import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_router.dart';
import 'package:easybook_app/core/router/placeholder_page.dart';
import 'package:easybook_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the bottom navigation switches between the four tabs', (
    tester,
  ) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
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
