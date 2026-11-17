import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Springs its child into place once, when first built: it fades in,
/// rises from below and grows from [AppMotion.entranceScale] with a small
/// overshoot.
///
/// Give list items an [index] for a staggered entrance: each item starts
/// [AppDurations.stagger] after the previous one. Only the first
/// [AppMotion.maxStaggeredItems] are delayed, so items built later while
/// scrolling appear right away.
///
/// The delay is part of a single animation (no timers), and the effect is
/// skipped when the user turned on "remove animations" in system settings.
class FadeSlideIn extends StatefulWidget {
  const new({
    required this.child,
    this.index = 0,
    this.offset = AppMotion.entranceOffset,
    this.axis = Axis.vertical,
    super.key,
  });

  final Widget child;

  /// Position in a list, for the stagger.
  final int index;

  /// How far from its final position the child starts.
  final double offset;

  /// Vertical rises from below; horizontal slides in from the right.
  final Axis axis;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final Duration _delay = widget.index < AppMotion.maxStaggeredItems
      ? AppDurations.stagger * widget.index
      : Duration.zero;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.entrance + _delay,
  );

  // The first part of the controller's run is the delay.
  late final double _start =
      _delay.inMilliseconds / _controller.duration!.inMilliseconds;

  late final Animation<double> _motion = CurvedAnimation(
    parent: _controller,
    curve: Interval(_start, 1, curve: AppMotion.enter),
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Interval(_start, (_start + 1) / 2, curve: AppMotion.smooth),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _motion.value;
        final shift = widget.offset * (1 - t);
        final scale =
            AppMotion.entranceScale + (1 - AppMotion.entranceScale) * t;
        return Opacity(
          opacity: _opacity.value.clamp(0, 1),
          child: Transform.translate(
            offset: widget.axis == Axis.vertical
                ? Offset(0, shift)
                : Offset(shift, 0),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }
}
