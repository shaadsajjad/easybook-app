import 'dart:math' as math;

import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// A one-shot burst of confetti from the top center that falls with
/// gravity, spinning and fading out. Paints over its area and ignores
/// touches. Shown when a booking succeeds.
class ConfettiBurst extends StatefulWidget {
  const new({required this.colors, this.count = 90, super.key});

  final List<Color> colors;
  final int count;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.confetti,
  );

  // A fixed seed: the same pleasing burst every time (and in tests).
  late final List<_Piece> _pieces = _Piece.generate(
    widget.count,
    widget.colors,
    math.Random(7),
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
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(animation: _controller, pieces: _pieces),
      ),
    );
  }
}

class _Piece {
  const new({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.size,
    required this.color,
    required this.round,
  });

  static List<_Piece> generate(int count, List<Color> colors, math.Random r) {
    return List.generate(
      count,
      (i) => _Piece(
        // Mostly upward, fanned out to both sides.
        angle: -math.pi / 2 + (r.nextDouble() - 0.5) * math.pi * 0.9,
        speed: 0.55 + r.nextDouble() * 0.6,
        spin: (r.nextDouble() - 0.5) * 18,
        size: 6 + r.nextDouble() * 7,
        color: colors[i % colors.length],
        round: r.nextBool(),
      ),
    );
  }

  final double angle;
  final double speed;
  final double spin;
  final double size;
  final Color color;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  new({required this.animation, required this.pieces})
    : super(repaint: animation);

  final Animation<double> animation;
  final List<_Piece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    if (t == 0 || t == 1) return;
    final origin = Offset(size.width / 2, size.height * 0.28);
    final reach = size.height * 0.9;
    final gravity = size.height * 1.4;
    final fade = t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;

    for (final p in pieces) {
      final v = p.speed * reach;
      final position =
          origin +
          Offset(
            math.cos(p.angle) * v * t,
            math.sin(p.angle) * v * t + 0.5 * gravity * t * t,
          );
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas
        ..save()
        ..translate(position.dx, position.dy)
        ..rotate(p.spin * t);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2.4, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.45,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => false;
}
