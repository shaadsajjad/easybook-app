import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The app's page transition: the new page zooms up from 92% while it
/// fades and slides in from below; the page underneath sinks back and dims.
///
/// Used on Android (and desktop). iOS keeps the native Cupertino slide so
/// the swipe-back gesture still works.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const new();

  @override
  Duration get transitionDuration => AppDurations.page;

  @override
  Duration get reverseTransitionDuration => AppDurations.medium;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = CurvedAnimation(
      parent: animation,
      curve: AppMotion.smooth,
      reverseCurve: Curves.easeInCubic,
    );
    final exit = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.smooth,
    );

    // The page underneath: scale down a little and fade slightly.
    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 0.94).animate(exit),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.6).animate(exit),
        // The new page: zoom, fade and rise.
        child: FadeTransition(
          opacity: enter,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(enter),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(enter),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
