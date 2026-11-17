import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/app/status_bar_strip.dart';
import 'package:easybook_app/app/theme_mode_cubit.dart';
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

  Locale? _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.locale;
    if (_locale != null && _locale != locale) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildEverything());
    }
    _locale = locale;
  }

  /// `tr()` reads the language from a global, so a widget that shows a
  /// translated text does not know the language changed. After a switch,
  /// mark every widget for one rebuild. Unlike replacing the tree, this
  /// keeps all state (navigation, scroll position, the chat).
  void _rebuildEverything() {
    if (!mounted) return;
    void rebuild(Element element) {
      element
        ..markNeedsBuild()
        ..visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  void dispose() {
    _router.dispose();
    unawaited(_authBloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(create: (_) => ThemeModeCubit()),
      ],
      // Light, dark or follow the phone, as picked in Profile > Appearance.
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp.router(
          onGenerateTitle: (_) => LocaleKeys.app_name.tr(),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerConfig: _router,
          // Every screen starts below a solid status bar strip.
          builder: (context, child) =>
              StatusBarStrip(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
