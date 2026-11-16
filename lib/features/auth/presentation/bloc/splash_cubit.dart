import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/features/auth/domain/usecases/wake_server.dart';
import 'package:easybook_app/features/auth/presentation/bloc/splash_state.dart';

export 'splash_state.dart';

/// Wakes the sleeping server on app start and decides when to show the
/// "Waking up the server..." hint (only if it takes a few seconds).
class SplashCubit extends Cubit<SplashState> {
  new({
    required this._wakeServer,
    this._hintDelay = AppConstants.wakeUpHintDelay,
  }) : super(const SplashState());

  final WakeServer _wakeServer;
  final Duration _hintDelay;
  Timer? _hintTimer;

  Future<void> start() async {
    _hintTimer = Timer(_hintDelay, () {
      if (!isClosed) emit(const SplashState(showWakeUpHint: true));
    });

    // Success or failure, the hint has done its job once the server
    // answers: the session check finishes on its own and shows an error
    // if needed.
    await _wakeServer();
    _hintTimer?.cancel();
    if (!isClosed && state.showWakeUpHint) emit(const SplashState());
  }

  @override
  Future<void> close() {
    _hintTimer?.cancel();
    return super.close();
  }
}
