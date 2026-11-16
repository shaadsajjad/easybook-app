import 'package:easybook_app/core/router/app_router.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAuthRedirect', () {
    String? redirect(AuthStatus status, String location) =>
        resolveAuthRedirect(status: status, location: location);

    test('keeps everyone on splash while the session is checked', () {
      expect(redirect(AuthStatus.unknown, AppRoutes.splash), isNull);
      expect(redirect(AuthStatus.unknown, AppRoutes.home), AppRoutes.splash);
      expect(redirect(AuthStatus.unknown, AppRoutes.login), AppRoutes.splash);
    });

    test('sends logged-out users to login, but lets them register', () {
      expect(
        redirect(AuthStatus.unauthenticated, AppRoutes.splash),
        AppRoutes.login,
      );
      expect(
        redirect(AuthStatus.unauthenticated, AppRoutes.bookings),
        AppRoutes.login,
      );
      expect(redirect(AuthStatus.unauthenticated, AppRoutes.login), isNull);
      expect(redirect(AuthStatus.unauthenticated, AppRoutes.register), isNull);
    });

    test('never shows splash, login or register to logged-in users', () {
      for (final page in [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
      ]) {
        expect(redirect(AuthStatus.authenticated, page), AppRoutes.home);
      }
      expect(redirect(AuthStatus.authenticated, AppRoutes.profile), isNull);
      expect(
        redirect(AuthStatus.authenticated, AppRoutes.bookingDetailPath('1')),
        isNull,
      );
    });
  });
}
