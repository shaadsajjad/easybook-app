import 'dart:async';

import 'package:flutter/widgets.dart';

/// Tells the tab pages when the user taps the bottom-navigation tab that is
/// already selected. The app shell creates it; pages listen with
/// [TabReselectListener] and refresh themselves.
///
/// It keeps pages independent of the shell: a page only knows its own tab
/// index, not how the navigation bar works.
class TabReselectScope extends InheritedWidget {
  const new({required this.reselections, required super.child, super.key});

  /// Emits the index of the tab that was tapped again.
  final Stream<int> reselections;

  static Stream<int>? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<TabReselectScope>()
      ?.reselections;

  @override
  bool updateShouldNotify(TabReselectScope oldWidget) =>
      reselections != oldWidget.reselections;
}

/// Calls [onReselect] when the user taps the already-selected [tab].
/// Does nothing outside the app shell (for example in widget tests).
class TabReselectListener extends StatefulWidget {
  const new({
    required this.tab,
    required this.onReselect,
    required this.child,
    super.key,
  });

  final int tab;
  final VoidCallback onReselect;
  final Widget child;

  @override
  State<TabReselectListener> createState() => _TabReselectListenerState();
}

class _TabReselectListenerState extends State<TabReselectListener> {
  StreamSubscription<int>? _subscription;
  Stream<int>? _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stream = TabReselectScope.maybeOf(context);
    if (stream == _stream) return;
    unawaited(_subscription?.cancel());
    _stream = stream;
    _subscription = stream?.listen((tab) {
      if (tab == widget.tab && mounted) widget.onReselect();
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
