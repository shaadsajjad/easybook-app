import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Centers its child and caps its width, so pages look right on tablets.
class ResponsiveCenter extends StatelessWidget {
  const new({
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
