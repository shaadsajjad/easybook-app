import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
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
        // An ink panel with rounded top corners. The faint outline and the
        // shadow keep it apart from the page in dark mode too.
        color: context.palette.hero,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        border: Border.all(
          color: context.palette.onHero.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.palette.cardShadow,
            blurRadius: AppElevation.cardBlur,
            offset: const Offset(0, -AppElevation.cardOffsetY),
          ),
        ],
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
                    AppIcons.slotChosen,
                    size: AppSizes.iconSm,
                    color: slot == null
                        ? context.palette.onHeroMuted
                        : context.palette.accent,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    // The summary slides in fresh each time a time is picked.
                    child: AnimatedSwitcher(
                      duration: AppDurations.medium,
                      transitionBuilder: (child, animation) => SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.centerLeft,
                        children: [...previous, ?current],
                      ),
                      child: Text(
                        summary,
                        key: ValueKey(summary),
                        style: context.textTheme.titleSmall?.copyWith(
                          color: slot == null
                              ? context.palette.onHeroMuted
                              : context.palette.onHero,
                        ),
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
