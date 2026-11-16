import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_router.dart';
import 'package:easybook_app/core/theme/app_theme.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// The root widget: the app-wide AuthBloc, theme, localization and router.
class App extends StatefulWidget {
  const new({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // The only app-level bloc. It checks the stored token right away; the
  // splash screen shows until it knows the answer.
  late final AuthBloc _authBloc = getIt<AuthBloc>()
    ..add(const AuthSessionRequested());

  // Created once, so locale changes keep the navigation stack.
  late final GoRouter _router = createAppRouter(_authBloc);

  @override
  void dispose() {
    _router.dispose();
    unawaited(_authBloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        onGenerateTitle: (_) => LocaleKeys.app_name.tr(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: _router,
      ),
    );
  }
}
