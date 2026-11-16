import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/status_colors.dart';
import 'package:easybook_app/core/widgets/status_chip.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment_status.dart';
import 'package:flutter/material.dart';

/// How each status looks: a translated label and a color tone.
extension AppointmentStatusDisplay on AppointmentStatus {
  String get label => switch (this) {
    AppointmentStatus.pending => LocaleKeys.appointments_status_pending.tr(),
    AppointmentStatus.confirmed =>
      LocaleKeys.appointments_status_confirmed.tr(),
    AppointmentStatus.cancelled =>
      LocaleKeys.appointments_status_cancelled.tr(),
    AppointmentStatus.completed =>
      LocaleKeys.appointments_status_completed.tr(),
  };

  StatusTone get tone => switch (this) {
    AppointmentStatus.pending => StatusTone.warning,
    AppointmentStatus.confirmed => StatusTone.info,
    AppointmentStatus.cancelled => StatusTone.neutral,
    AppointmentStatus.completed => StatusTone.success,
  };
}

class AppointmentStatusChip extends StatelessWidget {
  const new({required this.status, super.key});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusChip(label: status.label, tone: status.tone);
  }
}
