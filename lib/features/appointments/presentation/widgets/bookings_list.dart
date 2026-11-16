import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/empty_view.dart';
import 'package:easybook_app/core/widgets/error_view.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/core/widgets/skeleton.dart';
import 'package:easybook_app/features/appointments/domain/entities/bookings_tab.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/my_bookings_cubit.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/booking_card.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/booking_card_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// One tab of My Bookings, with pull to refresh and every state.
class BookingsList extends StatefulWidget {
  const new({required this.tab, super.key});

  final BookingsTab tab;

  @override
  State<BookingsList> createState() => _BookingsListState();
}

// Keeps the scroll position when switching tabs.
class _BookingsListState extends State<BookingsList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tab = widget.tab;
    return BlocBuilder<MyBookingsCubit, MyBookingsState>(
      buildWhen: (previous, current) => previous.of(tab) != current.of(tab),
      builder: (context, state) {
        final cubit = context.read<MyBookingsCubit>();
        final list = state.of(tab);

        if (list.status == BookingsStatus.failure) {
          return ErrorView(
            message: list.failure?.displayMessage ?? '',
            onRetry: () => cubit.load(tab),
          );
        }
        final isFirstLoad =
            list.appointments.isEmpty &&
            (list.status == BookingsStatus.loading ||
                list.status == BookingsStatus.initial);

        return RefreshIndicator(
          onRefresh: () => cubit.load(tab),
          child: list.isEmpty
              ? _EmptyTab(tab: tab)
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.lg,
                    AppSpacing.page,
                    AppSpacing.xxl,
                  ),
                  itemCount: isFirstLoad ? 3 : list.appointments.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    if (isFirstLoad) {
                      return const ResponsiveCenter(
                        child: Shimmer(child: BookingCardSkeleton()),
                      );
                    }
                    final appointment = list.appointments[index];
                    return ResponsiveCenter(
                      child: BookingCard(
                        appointment: appointment,
                        highlightDate: tab == BookingsTab.upcoming,
                        onTap: () => context.push(
                          AppRoutes.bookingDetailPath(appointment.id),
                          extra: appointment,
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const new({required this.tab});

  final BookingsTab tab;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = tab == BookingsTab.upcoming;
    // A scroll view, so pull to refresh also works on an empty tab.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: EmptyView(
            icon: isUpcoming
                ? Icons.event_available_rounded
                : Icons.history_rounded,
            title: isUpcoming
                ? LocaleKeys.appointments_empty_upcoming_title.tr()
                : LocaleKeys.appointments_empty_past_title.tr(),
            message: isUpcoming
                ? LocaleKeys.appointments_empty_upcoming_message.tr()
                : LocaleKeys.appointments_empty_past_message.tr(),
            actionLabel: isUpcoming
                ? LocaleKeys.appointments_browse_services.tr()
                : null,
            onAction: () => context.go(AppRoutes.home),
          ),
        ),
      ),
    );
  }
}
