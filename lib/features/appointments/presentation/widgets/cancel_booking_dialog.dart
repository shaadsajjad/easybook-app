import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/date_formatter.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:flutter/material.dart';

/// "Cancel this booking?" Returns true only when the user confirms.
abstract final class CancelBookingDialog {
  static Future<bool> show(
    BuildContext context,
    Appointment appointment,
  ) async {
    final locale = context.localeName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          AppIcons.cancelBooking,
          color: Theme.of(dialogContext).colorScheme.error,
        ),
        title: Text(LocaleKeys.appointments_cancel_confirm_title.tr()),
        content: Text(
          LocaleKeys.appointments_cancel_confirm_message.tr(
            namedArgs: {
              'service': appointment.service.name,
              'date': DateFormatter.fullDate(appointment.startTime, locale),
              'time': DateFormatter.time(appointment.startTime, locale),
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(LocaleKeys.appointments_keep_booking.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              minimumSize: const Size(0, AppSizes.minTapTarget),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(LocaleKeys.appointments_confirm_cancel.tr()),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
