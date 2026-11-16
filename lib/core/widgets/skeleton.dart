import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// Adds a moving shimmer to every [SkeletonBox] below it.
/// Wrap a whole skeleton layout once, not each box.
class Shimmer extends StatefulWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.shimmer,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.palette.surfaceMuted;
    final highlight = context.colors.surface;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final shift = _controller.value * 3 - 1;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(shift - 1, 0),
            end: Alignment(shift + 1, 0),
            colors: [base, highlight, base],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

/// A grey placeholder block shown while content loads.
class SkeletonBox extends StatelessWidget {
  const new({this.width, this.height, this.radius = AppRadius.sm, super.key});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
