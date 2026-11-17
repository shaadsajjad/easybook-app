import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Rings that keep expanding and fading out behind [child], like a radar
/// ping. Used behind the splash logo, the booking success badge and the
/// assistant avatar while it is typing.
class PulseRings extends StatefulWidget {
  const new({
    required this.child,
    required this.color,
    required this.size,
    this.rings = 3,
    this.active = true,
    super.key,
  });

  final Widget child;
  final Color color;

  /// Diameter of the child; rings grow to twice this.
  final double size;
  final int rings;
  final bool active;

  @override
  State<PulseRings> createState() => _PulseRingsState();
}

class _PulseRingsState extends State<PulseRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.pulse,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(PulseRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final run = widget.active && !MediaQuery.disableAnimationsOf(context);
    if (run && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!run) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extent = widget.size * 2;
    return SizedBox.square(
      dimension: extent,
      child: CustomPaint(
        painter: _RingsPainter(
          animation: _controller,
          color: widget.color,
          rings: widget.rings,
          innerRadius: widget.size / 2,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  new({
    required this.animation,
    required this.color,
    required this.rings,
    required this.innerRadius,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final int rings;
  final double innerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0) return;
    final center = size.center(Offset.zero);
    final maxGrowth = size.width / 2 - innerRadius;
    for (var i = 0; i < rings; i++) {
      // Each ring is offset in time, so they follow one another.
      final t = (animation.value + i / rings) % 1;
      canvas.drawCircle(
        center,
        innerRadius + maxGrowth * Curves.easeOut.transform(t),
        Paint()
          ..color = color.withValues(alpha: (1 - t) * 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.rings != rings;
}
