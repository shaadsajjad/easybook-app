import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/app/app.dart';
import 'package:easybook_app/core/config/app_config.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/localization/app_locales.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Logs bloc state changes in the development flavor. Only state TYPES are
/// logged, never their contents (they can hold personal data).
class AppBlocObserver extends BlocObserver {
  const new();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log(
      '${bloc.runtimeType}: ${change.currentState.runtimeType} -> '
      '${change.nextState.runtimeType}',
      name: 'bloc',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('${bloc.runtimeType} error', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}

/// Shared start-up for every flavor.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  await EasyLocalization.ensureInitialized();
  if (!config.enableLogging) {
    EasyLocalization.logger.enableBuildModes = [];
  }
  // Date names for English and Bengali (used by intl's DateFormat).
  await initializeDateFormatting();

  configureDependencies(config);
  if (config.enableLogging) {
    Bloc.observer = const AppBlocObserver();
  }

  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supported,
      fallbackLocale: AppLocales.fallback,
      path: AppLocales.path,
      child: const App(),
    ),
  );
}
