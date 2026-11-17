import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Gives the system status bar (clock, battery, camera cutout) its own
/// solid ink strip at the top of every screen, with light icons.
///
/// It wraps the whole app (MaterialApp.builder), so every page, dialog and
/// bottom sheet starts below the status bar: nothing ever runs underneath
/// the clock, and no page has to handle it on its own.
class StatusBarStrip extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The status bar reads its icon colour from this region.
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: ColoredBox(
            color: context.palette.hero,
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.paddingOf(context).top,
            ),
          ),
        ),
        Expanded(
          // Everything below already sits under the status bar, so the top
          // inset is removed: pages don't add it a second time.
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ],
    );
  }
}
