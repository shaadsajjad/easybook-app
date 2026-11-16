import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/app/shell/app_shell.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/router/placeholder_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// The app's routes.
///
/// Tabs live in a [StatefulShellRoute] so each tab keeps its own history.
/// Detail screens use the root navigator, so they cover the bottom bar.
///
/// Step 3 (auth) adds the `redirect` driven by AuthBloc and makes /splash
/// the initial location.
GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (context, state) =>
            PlaceholderPage(title: LocaleKeys.pages_splash.tr()),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRouteNames.login,
        builder: (context, state) =>
            PlaceholderPage(title: LocaleKeys.pages_login.tr()),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRouteNames.register,
        builder: (context, state) =>
            PlaceholderPage(title: LocaleKeys.pages_register.tr()),
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
                builder: (context, state) =>
                    PlaceholderPage(title: LocaleKeys.nav_home.tr()),
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
                builder: (context, state) =>
                    PlaceholderPage(title: LocaleKeys.nav_profile.tr()),
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
        builder: (context, state) =>
            PlaceholderPage(title: LocaleKeys.pages_service_detail.tr()),
      ),
      GoRoute(
        path: AppRoutes.bookService,
        name: AppRouteNames.bookService,
        builder: (context, state) =>
            PlaceholderPage(title: LocaleKeys.pages_book_service.tr()),
      ),
      GoRoute(
        path: AppRoutes.bookingConfirmation,
        name: AppRouteNames.bookingConfirmation,
        builder: (context, state) =>
            PlaceholderPage(title: LocaleKeys.pages_booking_confirmation.tr()),
      ),
    ],
  );
}
