import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// A glowing lime circle that scales in, then a check mark that draws
/// itself stroke by stroke. Shown on the booking confirmation.
class SuccessCheck extends StatefulWidget {
  const new({super.key});

  @override
  State<SuccessCheck> createState() => _SuccessCheckState();
}

class _SuccessCheckState extends State<SuccessCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.check,
  );

  // First 45%: the circle pops in. From 35% on: the check is drawn.
  late final Animation<double> _circle = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.45, curve: Curves.easeOutBack),
  );
  late final Animation<double> _stroke = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
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
    final color = context.palette.onSolidFill;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Transform.scale(
        scale: _circle.value,
        child: Container(
          width: AppSizes.confirmationIcon,
          height: AppSizes.confirmationIcon,
          decoration: BoxDecoration(
            color: context.palette.solidFill,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.palette.glow,
                blurRadius: AppElevation.cardBlur * 2,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _CheckPainter(progress: _stroke.value, color: color),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const new({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final w = size.width;
    final path = Path()
      ..moveTo(w * 0.30, w * 0.52)
      ..lineTo(w * 0.44, w * 0.65)
      ..lineTo(w * 0.70, w * 0.38);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSizes.checkStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw only the first `progress` share of the path's length.
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
