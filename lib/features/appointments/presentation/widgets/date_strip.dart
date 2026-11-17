import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/date_formatter.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// A horizontal row of days (weekday, number, month) to pick from.
class DateStrip extends StatelessWidget {
  const new({
    required this.days,
    required this.selected,
    required this.onSelected,
    required this.horizontalPadding,
    super.key,
  });

  final List<DateTime> days;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    // Taller chips when the user enlarges text.
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.6);
    return SizedBox(
      height: AppSizes.dayChipWidth * 1.4 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) => _DayChip(
          day: days[index],
          isToday: index == 0,
          selected: days[index] == selected,
          onTap: () => onSelected(days[index]),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const new({
    required this.day,
    required this.isToday,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = context.localeName;
    final palette = context.palette;
    // Selected: an ink tile with a lime day number that pops up.
    final foreground = selected ? palette.accent : context.colors.onSurface;
    final muted = selected ? palette.onHeroMuted : palette.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: DateFormatter.fullDate(day, locale),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedScale(
            scale: selected ? 1 : 0.9,
            duration: AppDurations.slow,
            curve: AppMotion.pop,
            child: AnimatedContainer(
              duration: AppDurations.medium,
              curve: AppMotion.standard,
              width: AppSizes.dayChipWidth,
              decoration: BoxDecoration(
                color: selected ? palette.hero : context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: selected ? palette.hero : context.colors.outline,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: palette.cardShadow,
                          blurRadius: AppElevation.cardBlur,
                          offset: const Offset(0, AppElevation.cardOffsetY),
                        ),
                      ]
                    : null,
              ),
              // Shrinks the labels rather than overflow with very large text.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isToday
                          ? LocaleKeys.booking_today.tr()
                          : DateFormatter.weekdayShort(day, locale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      DateFormatter.dayOfMonth(day, locale),
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: foreground,
                      ),
                    ),
                    Text(
                      DateFormatter.monthShort(day, locale),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
