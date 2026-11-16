import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/date_formatter.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_button.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Sticky bottom bar: the chosen day and time, and "Confirm booking".
/// The button is disabled until a time is picked and while booking.
class BookingSummaryBar extends StatelessWidget {
  const new({required this.onConfirm, super.key});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BookingCubit>().state;
    final slot = state.selectedSlot;
    final locale = context.localeName;
    final summary = slot == null
        ? LocaleKeys.booking_choose_time_first.tr()
        : LocaleKeys.booking_selected_time.tr(
            namedArgs: {
              'date': DateFormatter.fullDate(slot.start, locale),
              'time': DateFormatter.time(slot.start, locale),
            },
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: AppSizes.iconSm,
                    color: slot == null
                        ? context.palette.textSecondary
                        : context.colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      summary,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: slot == null
                            ? context.palette.textSecondary
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: LocaleKeys.booking_confirm.tr(),
                isLoading: state.isSubmitting,
                onPressed: slot == null ? null : onConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
