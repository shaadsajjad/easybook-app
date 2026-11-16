import 'dart:async';

/// Broadcasts "the session has expired" when a protected request gets a 401.
///
/// The AuthInterceptor calls [notify]; AuthBloc listens to [stream] and
/// logs the user out, which makes the router redirect to the login screen.
class SessionExpiryNotifier {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}
