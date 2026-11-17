import 'dart:math' as math;

import 'package:easybook_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The EasyBook logo, drawn in code so it is sharp at every size:
/// an ink rounded square holding a lime calendar page, with the header
/// line, the gaps around the binder rings and the check mark cut out.
///
/// [progress] (0 to 1) builds the logo piece by piece: the page pops in,
/// the rings drop onto it, then the check mark draws itself. The splash
/// screen animates it; everywhere else it is simply 1 (complete).
///
/// The same shapes are used by `tool/generate_icons.py` for the app icon.
class AppLogo extends StatelessWidget {
  const new({
    required this.size,
    this.showBackground = true,
    this.progress = 1,
    super.key,
  });

  final double size;

  /// False draws only the calendar and check (for ink backgrounds).
  final bool showBackground;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'EasyBook',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _LogoPainter(
          showBackground: showBackground,
          progress: progress,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const new({required this.showBackground, required this.progress});

  final bool showBackground;
  final double progress;

  // The design is drawn on a 1024 x 1024 canvas, then scaled.
  static const double _canvas = 1024;
  static const List<double> _ringsX = [400, 624];

  /// The part of [progress] between [start] and [end], eased, as 0..1.
  double _phase(double start, double end, Curve curve) {
    final t = ((progress - start) / (end - start)).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / _canvas);

    if (showBackground) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, _canvas, _canvas),
          const Radius.circular(228),
        ),
        Paint()..color = AppColors.ink,
      );
    }

    final pagePop = _phase(0, 0.45, Curves.easeOutBack);
    final ringsDrop = _phase(0.3, 0.65, Curves.easeOutBack);
    final checkDraw = _phase(0.55, 1, Curves.easeInOutCubic);

    final lime = Paint()..color = AppColors.lime;
    final cut = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Calendar page, popping in from its center.
    const center = Offset(512, 536);
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(math.max(pagePop, 0.001))
      ..translate(-center.dx, -center.dy);
    final page = RRect.fromRectAndRadius(
      const Rect.fromLTRB(240, 296, 784, 776),
      const Radius.circular(104),
    );
    final drop = (1 - ringsDrop) * -160;
    canvas
      ..drawRRect(page, lime)
      // Cut-outs, kept inside the page.
      ..save()
      ..clipRRect(page)
      ..drawLine(
        const Offset(240, 432),
        const Offset(784, 432),
        cut
          ..strokeCap = StrokeCap.butt
          ..strokeWidth = 28,
      );
    cut
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 120;
    if (ringsDrop > 0) {
      for (final x in _ringsX) {
        canvas.drawLine(Offset(x, 224 + drop), Offset(x, 352 + drop), cut);
      }
    }
    canvas
      ..restore()
      ..restore();

    // Binder rings, dropping onto the page.
    if (ringsDrop > 0) {
      final ring = Paint()
        ..color = AppColors.lime.withValues(alpha: ringsDrop.clamp(0, 1))
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 64;
      for (final x in _ringsX) {
        canvas.drawLine(Offset(x, 224 + drop), Offset(x, 352 + drop), ring);
      }
    }

    // Check mark, drawn stroke by stroke.
    if (checkDraw > 0) {
      final check = Path()
        ..moveTo(390, 610)
        ..lineTo(484, 700)
        ..lineTo(646, 536);
      cut.strokeWidth = 64;
      for (final metric in check.computeMetrics()) {
        canvas.drawPath(metric.extractPath(0, metric.length * checkDraw), cut);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) =>
      oldDelegate.showBackground != showBackground ||
      oldDelegate.progress != progress;
}
