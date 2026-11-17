import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/booking_reference.dart';
import 'package:easybook_app/core/utils/date_formatter.dart';
import 'package:easybook_app/core/utils/duration_formatter.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/utils/price_formatter.dart';
import 'package:easybook_app/core/widgets/app_network_image.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/appointment_status_chip.dart';
import 'package:flutter/material.dart';

/// A ticket-style summary of a booking: service, date, time, duration,
/// price, status and notes. Used on the confirmation and detail screens.
class AppointmentTicket extends StatelessWidget {
  const new({required this.appointment, super.key});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final locale = context.localeName;
    final service = appointment.service;
    final notes = appointment.notes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: SizedBox.square(
                    dimension: AppSizes.avatar,
                    child: AppNetworkImage(url: service.imageUrl),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.category,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      Text(service.name, style: context.textTheme.titleMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppointmentStatusChip(status: appointment.status),
            const _DashedDivider(),
            _Row(
              icon: AppIcons.date,
              label: LocaleKeys.booking_detail_date.tr(),
              value: DateFormatter.fullDate(appointment.startTime, locale),
            ),
            _Row(
              icon: AppIcons.duration,
              label: LocaleKeys.booking_detail_time.tr(),
              value: DateFormatter.timeRange(
                appointment.startTime,
                appointment.endTime,
                locale,
              ),
            ),
            _Row(
              icon: AppIcons.timeSpan,
              label: LocaleKeys.booking_detail_duration.tr(),
              value: DurationFormatter.format(service.durationMinutes, locale),
            ),
            _Row(
              icon: AppIcons.price,
              label: LocaleKeys.booking_detail_price.tr(),
              value: PriceFormatter.format(service.price, locale: locale),
            ),
            if (notes != null && notes.isNotEmpty)
              _Row(
                icon: AppIcons.notes,
                label: LocaleKeys.booking_detail_notes.tr(),
                value: notes,
              ),
            const _DashedDivider(),
            Text(
              LocaleKeys.booking_detail_reference.tr(),
              style: context.textTheme.bodySmall,
            ),
            // A short number like "B-26047" instead of the long UUID.
            SelectableText(
              BookingReference.format(
                id: appointment.id,
                createdAt: appointment.createdAt,
              ),
              style: context.textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const new({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppSizes.iconSm,
            color: context.palette.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// The perforated line that makes the card look like a ticket.
class _DashedDivider extends StatelessWidget {
  const new();

  static const double _dash = 6;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxWidth / (_dash * 2)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => SizedBox(
                width: _dash,
                height: AppSizes.borderThin,
                child: ColoredBox(color: context.colors.outline),
              ),
            ),
          );
        },
      ),
    );
  }
}
