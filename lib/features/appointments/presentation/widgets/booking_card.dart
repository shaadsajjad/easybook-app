import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/date_formatter.dart';
import 'package:easybook_app/core/utils/extensions.dart';
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

  /// Gradient date block for upcoming bookings, muted for past ones.
  final bool highlightDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = context.localeName;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadow,
            blurRadius: AppElevation.cardBlur,
            offset: const Offset(0, AppElevation.cardOffsetY),
          ),
        ],
      ),
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
                          icon: Icons.schedule_rounded,
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
                    Icons.chevron_right_rounded,
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
    final strong = highlight
        ? context.colors.onPrimary
        : context.colors.onSurface;
    final soft = highlight
        ? context.colors.onPrimary.withValues(alpha: 0.85)
        : context.palette.textSecondary;

    return Container(
      width: AppSizes.dayChipWidth,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: highlight ? context.palette.brandGradient : null,
        color: highlight ? null : context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
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
