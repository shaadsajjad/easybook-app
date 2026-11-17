import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_button.dart';
import 'package:easybook_app/core/widgets/aurora_background.dart';
import 'package:easybook_app/core/widgets/confetti_burst.dart';
import 'package:easybook_app/core/widgets/fade_slide_in.dart';
import 'package:easybook_app/core/widgets/pulse_rings.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/appointment_ticket.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/success_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// "You're booked!" with the booking as a ticket. Shown straight from the
/// POST response, so no extra request is needed.
class BookingConfirmationPage extends StatelessWidget {
  const new({required this.appointment, super.key});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Ink + aurora, a confetti burst, and the check drawing itself.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: palette.hero,
        body: AuroraBackground(
          child: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  child: ResponsiveCenter(
                    maxWidth: AppBreakpoints.maxFormWidth,
                    padding: const EdgeInsets.all(AppSpacing.page),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: PulseRings(
                            color: palette.accent,
                            size: AppSizes.confirmationIcon,
                            child: const SuccessCheck(),
                          ),
                        ),
                        FadeSlideIn(
                          index: 4,
                          child: Text(
                            LocaleKeys.booking_confirmed_title.tr(),
                            textAlign: TextAlign.center,
                            style: context.textTheme.headlineMedium?.copyWith(
                              color: palette.onHero,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        FadeSlideIn(
                          index: 5,
                          child: Text(
                            LocaleKeys.booking_confirmed_subtitle.tr(),
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: palette.onHeroMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        FadeSlideIn(
                          index: 6,
                          offset: AppMotion.entranceOffset * 3,
                          child: AppointmentTicket(appointment: appointment),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        FadeSlideIn(
                          index: 7,
                          child: AppButton(
                            label: LocaleKeys.booking_view_bookings.tr(),
                            icon: AppIcons.calendar,
                            onPressed: () => context.go(AppRoutes.bookings),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        FadeSlideIn(
                          index: 8,
                          child: AppButton(
                            label: LocaleKeys.booking_back_home.tr(),
                            variant: AppButtonVariant.secondary,
                            onPressed: () => context.go(AppRoutes.home),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: ConfettiBurst(
                  colors: [palette.accent, ...palette.aurora, palette.onHero],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
