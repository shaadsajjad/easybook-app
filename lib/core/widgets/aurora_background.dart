import 'dart:math' as math;

import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// An ink background with soft colored lights drifting slowly across it,
/// plus a faint dot grid for texture. Used behind every hero area (splash,
/// auth, home header, profile card, booking confirmation).
///
/// The lights move in a loop; with the system "remove animations" setting
/// they stay still.
class AuroraBackground extends StatefulWidget {
  const new({
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.intensity = 1,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;

  /// 0..1, how bright the lights are.
  final double intensity;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.aurora,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: CustomPaint(
        painter: _AuroraPainter(
          animation: _controller,
          base: palette.hero,
          lights: palette.aurora,
          dots: palette.onHero.withValues(alpha: 0.06),
          intensity: widget.intensity,
        ),
        child: widget.child,
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  new({
    required this.animation,
    required this.base,
    required this.lights,
    required this.dots,
    required this.intensity,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color base;
  final List<Color> lights;
  final Color dots;
  final double intensity;

  static const double _dotGap = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = base);

    // Each light travels its own slow loop (a Lissajous curve).
    final t = animation.value * 2 * math.pi;
    final radius = math.max(size.width, size.height) * 0.5;
    for (var i = 0; i < lights.length; i++) {
      final phase = i * 2.1;
      final center = Offset(
        size.width * (0.5 + 0.6 * math.sin(t + phase)),
        size.height * (0.3 + 0.6 * math.cos(t * 0.7 + phase * 1.3)),
      );
      final color = lights[i].withValues(alpha: 0.3 * intensity);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    // Faint dot grid.
    final dot = Paint()..color = dots;
    for (var x = _dotGap / 2; x < size.width; x += _dotGap) {
      for (var y = _dotGap / 2; y < size.height; y += _dotGap) {
        canvas.drawCircle(Offset(x, y), 1, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.base != base ||
      oldDelegate.intensity != intensity ||
      oldDelegate.lights != lights;
}
