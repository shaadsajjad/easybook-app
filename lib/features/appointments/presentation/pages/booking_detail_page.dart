import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/empty_view.dart';
import 'package:easybook_app/core/widgets/error_view.dart';
import 'package:easybook_app/core/widgets/fade_slide_in.dart';
import 'package:easybook_app/core/widgets/inline_banner.dart';
import 'package:easybook_app/core/widgets/loading_view.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment_status.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_detail_cubit.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/appointment_ticket.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/cancel_booking_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// One booking, with "Cancel booking" when it is still pending.
class BookingDetailPage extends StatelessWidget {
  const new({required this.appointmentId, this.initial, super.key});

  final String appointmentId;

  /// The tapped card, shown at once while the fresh copy loads.
  final Appointment? initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<BookingDetailCubit>();
        unawaited(cubit.load(appointmentId, initial: initial));
        return cubit;
      },
      child: BookingDetailView(appointmentId: appointmentId),
    );
  }
}

class BookingDetailView extends StatelessWidget {
  const new({required this.appointmentId, super.key});

  final String appointmentId;

  void _onCancelChanged(BuildContext context, BookingDetailState state) {
    switch (state.cancelStatus) {
      case CancelStatus.success:
        context.showSnackBar(LocaleKeys.appointments_cancelled_message.tr());
      case CancelStatus.failure:
        final failure = state.cancelFailure;
        if (failure != null) context.showSnackBar(failure.displayMessage);
      case CancelStatus.idle:
      case CancelStatus.cancelling:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingDetailCubit, BookingDetailState>(
      listenWhen: (previous, current) =>
          previous.cancelStatus != current.cancelStatus,
      listener: _onCancelChanged,
      child: Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.appointments_detail_title.tr())),
        body: BlocBuilder<BookingDetailCubit, BookingDetailState>(
          builder: (context, state) {
            final appointment = state.appointment;
            if (appointment != null) {
              return _DetailContent(
                appointment: appointment,
                isCancelling: state.isCancelling,
              );
            }
            if (state.status != BookingDetailStatus.failure) {
              return const LoadingView();
            }
            if (state.failure is NotFoundFailure) {
              return EmptyView(
                icon: AppIcons.noResults,
                title: LocaleKeys.appointments_not_found_title.tr(),
                message: LocaleKeys.appointments_not_found_message.tr(),
                actionLabel: LocaleKeys.appointments_back_to_bookings.tr(),
                onAction: () => context.go(AppRoutes.bookings),
              );
            }
            return ErrorView(
              message: state.failure?.displayMessage ?? '',
              onRetry: () =>
                  context.read<BookingDetailCubit>().load(appointmentId),
            );
          },
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const new({required this.appointment, required this.isCancelling});

  final Appointment appointment;
  final bool isCancelling;

  Future<void> _confirmCancel(BuildContext context) async {
    final cubit = context.read<BookingDetailCubit>();
    final confirmed = await CancelBookingDialog.show(context, appointment);
    if (confirmed) await cubit.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final status = appointment.status;
    return SingleChildScrollView(
      child: ResponsiveCenter(
        maxWidth: AppBreakpoints.maxFormWidth,
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeSlideIn(child: AppointmentTicket(appointment: appointment)),
            const SizedBox(height: AppSpacing.xl),
            if (appointment.canCancel)
              OutlinedButton.icon(
                onPressed: isCancelling ? null : () => _confirmCancel(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.error,
                  side: BorderSide(
                    color: context.colors.error.withValues(alpha: 0.5),
                  ),
                ),
                icon: isCancelling
                    ? SizedBox.square(
                        dimension: AppSizes.iconSm,
                        child: CircularProgressIndicator(
                          strokeWidth: AppSizes.progressStroke,
                          color: context.colors.error,
                        ),
                      )
                    : const Icon(AppIcons.cancelBooking),
                label: Text(LocaleKeys.appointments_cancel_button.tr()),
              )
            else if (status == AppointmentStatus.confirmed)
              InlineBanner(
                message: LocaleKeys.appointments_cannot_cancel_note.tr(),
                tone: InlineBannerTone.info,
              ),
          ],
        ),
      ),
    );
  }
}
