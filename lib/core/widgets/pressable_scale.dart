import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Shrinks its child slightly while a finger is down on it, and eases back
/// on release. Gives cards and buttons a tactile feel.
///
/// If the finger starts moving (the user is scrolling, not tapping) the
/// press is cancelled at once, so cards don't squash while a list scrolls.
///
/// It only listens to pointer events, so the child's own `onTap`, ripple
/// and semantics keep working unchanged.
class PressableScale extends StatefulWidget {
  const new({
    required this.child,
    this.enabled = true,
    this.pressedScale = AppMotion.pressedScale,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final double pressedScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;
  Offset? _downAt;

  void _set(bool pressed) {
    if (!widget.enabled || _pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  void _onDown(PointerDownEvent event) {
    _downAt = event.position;
    _set(true);
  }

  void _onMove(PointerMoveEvent event) {
    final start = _downAt;
    if (start != null && (event.position - start).distance > kTouchSlop) {
      _downAt = null;
      _set(false);
    }
  }

  void _onUp() {
    _downAt = null;
    _set(false);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: (_) => _onUp(),
      onPointerCancel: (_) => _onUp(),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: _pressed ? AppDurations.fast : AppDurations.medium,
        curve: _pressed ? AppMotion.standard : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
