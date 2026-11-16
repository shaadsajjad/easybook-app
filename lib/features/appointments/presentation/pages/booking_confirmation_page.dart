import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_button.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/appointment_ticket.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// "You're booked!" with the booking as a ticket. Shown straight from the
/// POST response, so no extra request is needed.
class BookingConfirmationPage extends StatelessWidget {
  const new({required this.appointment, super.key});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: AppBreakpoints.maxFormWidth,
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                const Center(child: _SuccessBadge()),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  LocaleKeys.booking_confirmed_title.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  LocaleKeys.booking_confirmed_subtitle.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppointmentTicket(appointment: appointment),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: LocaleKeys.booking_view_bookings.tr(),
                  icon: Icons.calendar_month_rounded,
                  onPressed: () => context.go(AppRoutes.bookings),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: LocaleKeys.booking_back_home.tr(),
                  variant: AppButtonVariant.text,
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A gradient circle with a check mark that pops in.
class _SuccessBadge extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.slow * 2,
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        width: AppSizes.confirmationIcon,
        height: AppSizes.confirmationIcon,
        decoration: BoxDecoration(
          gradient: context.palette.brandGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.35),
              blurRadius: AppElevation.cardBlur,
              offset: const Offset(0, AppElevation.cardOffsetY),
            ),
          ],
        ),
        child: Icon(
          Icons.check_rounded,
          size: AppSizes.iconXl,
          color: context.colors.onPrimary,
        ),
      ),
    );
  }
}
