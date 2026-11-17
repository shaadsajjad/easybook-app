import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/date_formatter.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/pressable_scale.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/appointment_status_chip.dart';
import 'package:easybook_app/features/services/presentation/widgets/info_pill.dart';
import 'package:easybook_app/features/services/presentation/widgets/price_tag.dart';
import 'package:flutter/material.dart';

/// A booking in the My Bookings list: a date block on the left, then the
/// service, time, status and price.
class BookingCard extends StatelessWidget {
  const new({
    required this.appointment,
    required this.highlightDate,
    required this.onTap,
    super.key,
  });

  final Appointment appointment;

  /// Brand-tinted date block for upcoming bookings, muted for past ones.
  final bool highlightDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = context.localeName;
    return PressableScale(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DateBlock(
                    date: appointment.startTime,
                    highlight: highlightDate,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appointment.service.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        InfoPill(
                          icon: AppIcons.duration,
                          label: DateFormatter.timeRange(
                            appointment.startTime,
                            appointment.endTime,
                            locale,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            AppointmentStatusChip(status: appointment.status),
                            PriceTag(price: appointment.service.price),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    AppIcons.chevronRight,
                    color: context.palette.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const new({required this.date, required this.highlight});

  final DateTime date;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final locale = context.localeName;
    final palette = context.palette;
    // Upcoming: an ink block with a lime day number. Past: muted.
    final strong = highlight ? palette.accent : context.colors.onSurface;
    final soft = highlight ? palette.onHeroMuted : palette.textSecondary;

    return Container(
      width: AppSizes.dayChipWidth,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: highlight ? palette.hero : palette.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormatter.weekdayShort(date, locale),
            style: context.textTheme.labelSmall?.copyWith(color: soft),
          ),
          Text(
            DateFormatter.dayOfMonth(date, locale),
            style: context.textTheme.headlineSmall?.copyWith(color: strong),
          ),
          Text(
            DateFormatter.monthShort(date, locale),
            style: context.textTheme.labelSmall?.copyWith(color: soft),
          ),
        ],
      ),
    );
  }
}
