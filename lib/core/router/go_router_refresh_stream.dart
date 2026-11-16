import 'dart:async';

import 'package:flutter/foundation.dart';

/// Turns a stream (for example AuthBloc's state stream) into a Listenable,
/// so GoRouter re-runs its redirect whenever the stream emits.
class GoRouterRefreshStream extends ChangeNotifier {
  new(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
