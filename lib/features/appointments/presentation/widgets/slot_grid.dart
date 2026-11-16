import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/date_formatter.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/inline_banner.dart';
import 'package:easybook_app/core/widgets/skeleton.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_cubit.dart';
import 'package:easybook_app/features/services/domain/entities/time_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The time slots of the selected day, with loading, error and empty
/// states. Unavailable slots are shown but disabled.
class SlotGrid extends StatelessWidget {
  const new({super.key});

  static const int _skeletonCount = 9;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      buildWhen: (previous, current) =>
          previous.slotsStatus != current.slotsStatus ||
          previous.availability != current.availability ||
          previous.selectedSlot != current.selectedSlot,
      builder: (context, state) {
        final cubit = context.read<BookingCubit>();
        switch (state.slotsStatus) {
          case SlotsStatus.initial:
          case SlotsStatus.loading:
            return Shimmer(
              child: _Grid(
                children: List.generate(
                  _skeletonCount,
                  (_) => const SkeletonBox(
                    height: AppSizes.minTapTarget,
                    radius: AppRadius.pill,
                  ),
                ),
              ),
            );
          case SlotsStatus.failure:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InlineBanner(
                  message:
                      state.slotsFailure?.displayMessage ??
                      LocaleKeys.booking_slots_error.tr(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: cubit.loadSlots,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(LocaleKeys.common_retry.tr()),
                  ),
                ),
              ],
            );
          case SlotsStatus.success:
            final availability = state.availability;
            if (availability == null || !availability.hasAvailableSlot) {
              return const _NoSlots();
            }
            return _Grid(
              children: [
                for (final slot in availability.slots)
                  _SlotChip(
                    slot: slot,
                    selected: slot == state.selectedSlot,
                    onTap: () => cubit.selectSlot(slot),
                  ),
              ],
            );
        }
      },
    );
  }
}

/// Lays chips out in equal columns (3 on phones, more on tablets).
class _Grid extends StatelessWidget {
  const new({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / AppSizes.slotChipMinWidth)
            .floor()
            .clamp(3, 6);
        final width =
            (constraints.maxWidth - AppSpacing.sm * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _SlotChip extends StatelessWidget {
  const new({required this.slot, required this.selected, required this.onTap});

  final TimeSlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = DateFormatter.time(slot.start, context.localeName);
    final enabled = slot.available;
    final Color textColor;
    if (selected) {
      textColor = context.colors.onPrimary;
    } else if (enabled) {
      textColor = context.colors.onSurface;
    } else {
      textColor = context.palette.textSecondary.withValues(alpha: 0.6);
    }

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: enabled
          ? time
          : LocaleKeys.booking_unavailable_slot.tr(namedArgs: {'time': time}),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(
              gradient: selected ? context.palette.brandGradient : null,
              color: selected
                  ? null
                  : enabled
                  ? context.colors.surface
                  : context.palette.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: selected || !enabled
                  ? null
                  : Border.all(color: context.colors.outline),
            ),
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: context.textTheme.labelLarge?.copyWith(
                color: textColor,
                decoration: enabled ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoSlots extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: AppSizes.iconLg,
            color: context.palette.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LocaleKeys.booking_no_slots_title.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            LocaleKeys.booking_no_slots_message.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
