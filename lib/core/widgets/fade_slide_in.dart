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
    this.scaleFrom = AppMotion.entranceScale,
    this.curve = AppMotion.enter,
    this.animate = true,
    super.key,
  });

  final Widget child;

  /// Position in a list, for the stagger.
  final int index;

  /// How far from its final position the child starts.
  final double offset;

  /// Vertical rises from below; horizontal slides in from the right.
  final Axis axis;

  /// Scale the child starts from (1 = no zoom).
  final double scaleFrom;

  /// Curve of the movement. The default springs with a small overshoot;
  /// use [AppMotion.smooth] for calm list items.
  final Curve curve;

  /// False shows the child at once. Only read when first built, so a
  /// rebuild never restarts or cuts an animation in progress.
  final bool animate;

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
    curve: Interval(_start, 1, curve: widget.curve),
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Interval(_start, (_start + 1) / 2, curve: AppMotion.smooth),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    if (!widget.animate || MediaQuery.disableAnimationsOf(context)) {
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
        final scale = widget.scaleFrom + (1 - widget.scaleFrom) * t;
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
