import 'dart:async';

import 'package:bloc/bloc.dart';

/// Bloc event transformer that waits until events stop arriving for
/// [duration], then handles only the last one. Used for search-as-you-type
/// so typing "massage" sends one request, not seven.
EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => _debounced(events, duration).asyncExpand(mapper);
}

Stream<E> _debounced<E>(Stream<E> source, Duration duration) {
  Timer? timer;
  StreamSubscription<E>? subscription;
  late final StreamController<E> controller;

  controller = StreamController<E>(
    onListen: () {
      subscription = source.listen(
        (event) {
          timer?.cancel();
          timer = Timer(duration, () => controller.add(event));
        },
        onError: controller.addError,
        onDone: () {
          timer?.cancel();
          unawaited(controller.close());
        },
      );
    },
    onCancel: () {
      timer?.cancel();
      return subscription?.cancel();
    },
  );
  return controller.stream;
}
