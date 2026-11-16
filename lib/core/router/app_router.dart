import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/app/shell/app_shell.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/router/go_router_refresh_stream.dart';
import 'package:easybook_app/core/router/placeholder_page.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/presentation/pages/booking_confirmation_page.dart';
import 'package:easybook_app/features/appointments/presentation/pages/booking_page.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/auth/presentation/pages/login_page.dart';
import 'package:easybook_app/features/auth/presentation/pages/register_page.dart';
import 'package:easybook_app/features/auth/presentation/pages/splash_page.dart';
import 'package:easybook_app/features/auth/presentation/widgets/logout_button.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/presentation/pages/home_page.dart';
import 'package:easybook_app/features/services/presentation/pages/service_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Where to send the user for a given session [status] and [location].
/// Returns null to stay. Kept as a plain function so it is easy to test.
///
/// - Still checking the token: stay on the splash screen.
/// - Logged out: only login and register are allowed.
/// - Logged in: never show splash, login or register.
String? resolveAuthRedirect({
  required AuthStatus status,
  required String location,
}) {
  final onSplash = location == AppRoutes.splash;
  final onAuthPage =
      location == AppRoutes.login || location == AppRoutes.register;

  return switch (status) {
    AuthStatus.unknown => onSplash ? null : AppRoutes.splash,
    AuthStatus.unauthenticated => onAuthPage ? null : AppRoutes.login,
    AuthStatus.authenticated => onSplash || onAuthPage ? AppRoutes.home : null,
  };
}

/// The app's routes.
///
/// Tabs live in a [StatefulShellRoute] so each tab keeps its own history.
/// Detail screens use the root navigator, so they cover the bottom bar.
/// The router re-checks [resolveAuthRedirect] every time [authBloc] emits.
GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) => resolveAuthRedirect(
      status: authBloc.state.status,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bookings,
                name: AppRouteNames.bookings,
                builder: (context, state) =>
                    PlaceholderPage(title: LocaleKeys.nav_bookings.tr()),
                routes: [
                  GoRoute(
                    path: AppRoutes.bookingDetail,
                    name: AppRouteNames.bookingDetail,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => PlaceholderPage(
                      title: LocaleKeys.pages_booking_detail.tr(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.assistant,
                name: AppRouteNames.assistant,
                builder: (context, state) =>
                    PlaceholderPage(title: LocaleKeys.nav_assistant.tr()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRouteNames.profile,
                // Step 7 replaces this with the real profile page.
                builder: (context, state) => PlaceholderPage(
                  title: LocaleKeys.nav_profile.tr(),
                  actions: const [LogoutButton()],
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.editProfile,
                    name: AppRouteNames.editProfile,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => PlaceholderPage(
                      title: LocaleKeys.pages_edit_profile.tr(),
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.changePassword,
                    name: AppRouteNames.changePassword,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => PlaceholderPage(
                      title: LocaleKeys.pages_change_password.tr(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.serviceDetail,
        name: AppRouteNames.serviceDetail,
        builder: (context, state) => ServiceDetailPage(
          serviceId: state.pathParameters[AppRoutes.idParam] ?? '',
          // The tapped card passes its service so the page shows at once.
          initial: switch (state.extra) {
            final Service service => service,
            _ => null,
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.bookService,
        name: AppRouteNames.bookService,
        builder: (context, state) => BookingPage(
          serviceId: state.pathParameters[AppRoutes.idParam] ?? '',
          initial: switch (state.extra) {
            final Service service => service,
            _ => null,
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.bookingConfirmation,
        name: AppRouteNames.bookingConfirmation,
        // Opened with the created booking as `extra`. Without it (for
        // example a restored deep link) there is nothing to show.
        redirect: (context, state) =>
            state.extra is Appointment ? null : AppRoutes.bookings,
        builder: (context, state) =>
            BookingConfirmationPage(appointment: state.extra! as Appointment),
      ),
    ],
  );
}
