import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/app/shell/app_nav_bar.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  /// The Assistant tab keeps the bar in place: its input bar sits on it.
  static const int _assistantTab = 2;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _navHidden = false;

  StatefulNavigationShell get _shell => widget.navigationShell;

  void _onTabSelected(int index) {
    setState(() => _navHidden = false);
    // Tapping the active tab again returns it to its first screen.
    _shell.goBranch(index, initialLocation: index == _shell.currentIndex);
  }

  bool _onScroll(UserScrollNotification notification) {
    // Only vertical page scrolls (not the carousel or the date strip).
    if (notification.metrics.axis != Axis.vertical ||
        _shell.currentIndex == AppShell._assistantTab) {
      return false;
    }
    final hide = switch (notification.direction) {
      ScrollDirection.reverse => true,
      ScrollDirection.forward => false,
      ScrollDirection.idle => _navHidden,
    };
    if (hide != _navHidden) setState(() => _navHidden = hide);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: NotificationListener<UserScrollNotification>(
        onNotification: _onScroll,
        child: _TabFade(index: _shell.currentIndex, child: _shell),
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
