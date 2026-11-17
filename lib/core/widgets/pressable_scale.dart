import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Squashes its child while a finger is down on it, and springs back with
/// a bounce on release. Gives cards and buttons a tactile feel.
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

  void _set(bool pressed) {
    if (!widget.enabled || _pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: _pressed ? AppDurations.fast : AppDurations.slow,
        curve: _pressed ? AppMotion.standard : AppMotion.pop,
        child: widget.child,
      ),
    );
  }
}
