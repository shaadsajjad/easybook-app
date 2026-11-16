import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_text_field.dart';
import 'package:easybook_app/core/widgets/error_view.dart';
import 'package:easybook_app/core/widgets/loading_view.dart';
import 'package:easybook_app/core/widgets/section_header.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/booking_cubit.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/booking_service_header.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/booking_summary_bar.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/date_strip.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/slot_grid.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/presentation/bloc/service_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Pick a day and a time for a service, add notes, and book.
class BookingPage extends StatelessWidget {
  const new({required this.serviceId, this.initial, super.key});

  final String serviceId;

  /// The service from the detail page, so the header shows at once.
  final Service? initial;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = getIt<ServiceDetailCubit>();
            unawaited(cubit.load(serviceId, initial: initial));
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) {
            final cubit = getIt<BookingCubit>();
            unawaited(cubit.start(serviceId));
            return cubit;
          },
        ),
      ],
      child: const BookingView(),
    );
  }
}

class BookingView extends StatefulWidget {
  const new({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _confirm() {
    FocusScope.of(context).unfocus();
    unawaited(context.read<BookingCubit>().submit(notes: _notes.text));
  }

  /// A 422 on booking carries the exact reason under `startTime`.
  String _submitError(Failure failure) => switch (failure) {
    ValidationFailure(:final errorFor) =>
      errorFor('startTime') ?? failure.displayMessage,
    _ => failure.displayMessage,
  };

  void _onStateChanged(BuildContext context, BookingState state) {
    final appointment = state.appointment;
    if (state.submitStatus == SubmitStatus.success && appointment != null) {
      // Replace the booking flow, so Back from the confirmation goes Home.
      context.go(AppRoutes.bookingConfirmation, extra: appointment);
      return;
    }
    final failure = state.submitFailure;
    if (state.submitStatus == SubmitStatus.failure && failure != null) {
      context.showSnackBar(_submitError(failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final inset = math.max(
      AppSpacing.page,
      (width - AppBreakpoints.maxContentWidth) / 2,
    );

    return BlocListener<BookingCubit, BookingState>(
      listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus,
      listener: _onStateChanged,
      child: Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.booking_title.tr())),
        bottomNavigationBar: BookingSummaryBar(onConfirm: _confirm),
        body: BlocBuilder<ServiceDetailCubit, ServiceDetailState>(
          builder: (context, serviceState) {
            final service = serviceState.service;
            if (service == null) {
              return serviceState.status == ServiceDetailStatus.failure
                  ? ErrorView(
                      message: serviceState.failure?.displayMessage ?? '',
                      onRetry: () => context.read<ServiceDetailCubit>().load(
                        context.read<BookingCubit>().serviceId,
                      ),
                    )
                  : const LoadingView();
            }
            return _BookingContent(
              service: service,
              inset: inset,
              notes: _notes,
            );
          },
        ),
      ),
    );
  }
}

class _BookingContent extends StatelessWidget {
  const new({required this.service, required this.inset, required this.notes});

  final Service service;
  final double inset;
  final TextEditingController notes;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingCubit>();
    final pagePadding = EdgeInsets.symmetric(horizontal: inset);
    final headerPadding = EdgeInsets.symmetric(
      horizontal: inset - AppSpacing.page,
    );

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        Padding(
          padding: pagePadding,
          child: BookingServiceHeader(service: service),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: headerPadding,
          child: SectionHeader(title: LocaleKeys.booking_pick_date.tr()),
        ),
        const SizedBox(height: AppSpacing.md),
        BlocSelector<BookingCubit, BookingState, DateTime>(
          selector: (state) => state.selectedDay,
          builder: (context, selectedDay) => DateStrip(
            days: cubit.state.days,
            selected: selectedDay,
            onSelected: cubit.selectDay,
            horizontalPadding: inset,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: headerPadding,
          child: SectionHeader(title: LocaleKeys.booking_pick_time.tr()),
        ),
        Padding(
          padding: pagePadding,
          child: Text(
            LocaleKeys.booking_local_time_note.tr(),
            style: context.textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(padding: pagePadding, child: const SlotGrid()),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: pagePadding,
          child: AppTextField(
            label: LocaleKeys.booking_notes_label.tr(),
            hint: LocaleKeys.booking_notes_hint.tr(),
            controller: notes,
            maxLines: 3,
            maxLength: AppConstants.notesMaxLength,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ],
    );
  }
}
