import 'dart:ui' show ImageFilter;

import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// One tab of [AppNavBar].
class AppNavItem {
  const new({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// The floating ink bottom bar. A lime pill slides (with a little bounce)
/// to the selected tab, whose icon pops; labels are always shown.
class AppNavBar extends StatelessWidget {
  const new({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const double _pillHeight = 34;
  static const double _pillWidth = 60;
  static const double _blur = 18;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          0,
        ),
        // Frosted glass: content scrolling underneath shows through,
        // blurred and tinted with ink.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.hero.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: palette.onHero.withValues(alpha: 0.08),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / items.length;
                    return Stack(
                      children: [
                        // The sliding lime pill behind the selected icon.
                        AnimatedPositioned(
                          duration: AppDurations.slow,
                          curve: AppMotion.enter,
                          top: AppSpacing.xxs,
                          left:
                              itemWidth * selectedIndex +
                              (itemWidth - _pillWidth) / 2,
                          width: _pillWidth,
                          height: _pillHeight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: palette.accent,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: palette.glow,
                                  blurRadius: AppElevation.cardBlur,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < items.length; i++)
                              Expanded(
                                child: _NavButton(
                                  item: items[i],
                                  selected: i == selectedIndex,
                                  onTap: () => onSelected(i),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const new({required this.item, required this.selected, required this.onTap});

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: ExcludeSemantics(
        child: InkResponse(
          onTap: onTap,
          radius: AppSizes.minTapTarget,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTapTarget + AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: AppNavBar._pillHeight + AppSpacing.xxs * 2,
                  child: Center(
                    child: AnimatedScale(
                      scale: selected ? 1.15 : 1,
                      duration: AppDurations.slow,
                      curve: AppMotion.pop,
                      child: AnimatedSwitcher(
                        duration: AppDurations.medium,
                        transitionBuilder: (child, animation) =>
                            RotationTransition(
                              turns: Tween<double>(
                                begin: -0.15,
                                end: 0,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                        child: Icon(
                          selected ? item.selectedIcon : item.icon,
                          key: ValueKey(selected),
                          size: AppSizes.navIcon,
                          color: selected
                              ? palette.onSolidFill
                              : palette.onHeroMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedDefaultTextStyle(
                    duration: AppDurations.medium,
                    style: context.textTheme.labelSmall!.copyWith(
                      color: selected ? palette.accent : palette.onHeroMuted,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                    child: Text(item.label, maxLines: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
