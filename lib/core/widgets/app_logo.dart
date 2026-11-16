import 'package:easybook_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The EasyBook logo, drawn in code so it is sharp at every size:
/// a gradient rounded square with a white calendar and a coral check.
///
/// The same shapes are used by `tool/generate_icons.py` for the app icon.
class AppLogo extends StatelessWidget {
  const new({required this.size, this.showBackground = true, super.key});

  final double size;

  /// False draws only the calendar and check (for gradient backgrounds).
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'EasyBook',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _LogoPainter(showBackground: showBackground),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const new({required this.showBackground});

  final bool showBackground;

  // The design is drawn on a 1024 x 1024 canvas, then scaled.
  static const double _canvas = 1024;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / _canvas);

    if (showBackground) {
      const rect = Rect.fromLTWH(0, 0, _canvas, _canvas);
      final background = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandIndigo, AppColors.brandViolet],
        ).createShader(rect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(230)),
        background,
      );
    }

    final white = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 56;

    // Calendar body and header line.
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(232, 268, 560, 500),
          const Radius.circular(84),
        ),
        white,
      )
      ..drawLine(const Offset(232, 410), const Offset(792, 410), white);

    // Binder rings.
    final rings = Paint()
      ..color = AppColors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 60;
    canvas
      ..drawLine(const Offset(384, 200), const Offset(384, 320), rings)
      ..drawLine(const Offset(640, 200), const Offset(640, 320), rings);

    // Coral check mark.
    final check = Paint()
      ..color = AppColors.accentCoral
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 72;
    final path = Path()
      ..moveTo(376, 590)
      ..lineTo(480, 690)
      ..lineTo(662, 500);
    canvas
      ..drawPath(path, check)
      ..restore();
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) =>
      oldDelegate.showBackground != showBackground;
}
