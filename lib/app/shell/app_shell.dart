import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/app/shell/app_nav_bar.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/widgets/tab_reselect.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The scaffold around the four main tabs, with the bottom navigation bar.
///
/// Pages scroll underneath the see-through bar (`extendBody`), and the bar
/// slides away while scrolling down and comes back when scrolling up, so it
/// never hides content for long. Scroll views add
/// `MediaQuery.paddingOf(context).bottom` so their last item clears it.
class AppShell extends StatefulWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _navHidden = false;

  /// Tabs tapped again while already selected (pages refresh on it).
  final _reselections = StreamController<int>.broadcast();

  StatefulNavigationShell get _shell => widget.navigationShell;

  @override
  void dispose() {
    unawaited(_reselections.close());
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _navHidden = false);
    final reselected = index == _shell.currentIndex;
    // Tapping the active tab again returns it to its first screen and
    // tells that page to refresh.
    _shell.goBranch(index, initialLocation: reselected);
    if (reselected) _reselections.add(index);
  }

  /// Scroll distance in the current direction since it last changed.
  double _scrolled = 0;

  /// Hides the bar after scrolling down a little and shows it after
  /// scrolling up a little. Small jitters (a finger lifting usually moves
  /// the list a pixel back) are ignored, and the bar is always shown at the
  /// top of the page.
  bool _onScroll(ScrollUpdateNotification notification) {
    final metrics = notification.metrics;
    // Only vertical page scrolls (not the carousel or the date strip).
    if (metrics.axis != Axis.vertical ||
        // The Assistant keeps the bar in place: its input bar sits on it.
        _shell.currentIndex == AppTabs.assistant) {
      return false;
    }
    final delta = notification.scrollDelta ?? 0;
    if (delta == 0) return false;
    // Restart the count when the direction changes.
    if (delta.sign != _scrolled.sign) _scrolled = 0;
    _scrolled += delta;

    final atTop = metrics.pixels <= metrics.minScrollExtent;
    final hide = switch (_scrolled) {
      _ when atTop => false,
      > AppMotion.navToggleDistance => true,
      < -AppMotion.navToggleDistance => false,
      _ => _navHidden,
    };
    if (hide != _navHidden) setState(() => _navHidden = hide);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // The Stack adds a solid strip behind the Android system keys.
    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          body: NotificationListener<ScrollUpdateNotification>(
            onNotification: _onScroll,
            child: TabReselectScope(
              reselections: _reselections.stream,
              child: _TabFade(index: _shell.currentIndex, child: _shell),
            ),
          ),
          bottomNavigationBar: AnimatedSlide(
            offset: _navHidden ? const Offset(0, 1.4) : Offset.zero,
            duration: AppDurations.slow,
            curve: AppMotion.standard,
            child: AppNavBar(
              selectedIndex: _shell.currentIndex,
              onSelected: _onTabSelected,
              items: [
                AppNavItem(
                  icon: AppIcons.home,
                  selectedIcon: AppIcons.homeSelected,
                  label: LocaleKeys.nav_home.tr(),
                ),
                AppNavItem(
                  icon: AppIcons.bookings,
                  selectedIcon: AppIcons.bookingsSelected,
                  label: LocaleKeys.nav_bookings.tr(),
                ),
                AppNavItem(
                  icon: AppIcons.assistant,
                  selectedIcon: AppIcons.assistantSelected,
                  label: LocaleKeys.nav_assistant.tr(),
                ),
                AppNavItem(
                  icon: AppIcons.profile,
                  selectedIcon: AppIcons.profileSelected,
                  label: LocaleKeys.nav_profile.tr(),
                ),
              ],
            ),
          ),
        ),
        const _SystemBarBackdrop(),
      ],
    );
  }
}

/// A solid strip, in the page color, behind Android's system bottom bar
/// (the Back/Home/Recents keys or the gesture handle).
///
/// Android draws apps edge-to-edge, so without it the list scrolling under
/// the floating navigation bar would also show through the system keys.
/// iOS is left as is: its home indicator is only a thin line.
class _SystemBarBackdrop extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.viewPaddingOf(context).bottom;
    if (height == 0 || Theme.of(context).platform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: height,
      child: IgnorePointer(
        child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
      ),
    );
  }
}

/// Fades the tab content in (with a tiny rise) whenever the tab changes.
///
/// The navigation shell keeps every tab alive in an IndexedStack, so the
/// shell itself is never rebuilt or duplicated; only its opacity animates.
class _TabFade extends StatefulWidget {
  const new({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_TabFade> createState() => _TabFadeState();
}

class _TabFadeState extends State<_TabFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
    value: 1,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.enter,
  );

  @override
  void didUpdateWidget(_TabFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (oldWidget.index != widget.index && !reduceMotion) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: _curve.drive(
          Tween(begin: const Offset(0.04, 0), end: Offset.zero),
        ),
        child: widget.child,
      ),
    );
  }
}
