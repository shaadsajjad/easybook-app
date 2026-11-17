import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/appointments/domain/entities/bookings_tab.dart';
import 'package:easybook_app/features/appointments/presentation/bloc/my_bookings_cubit.dart';
import 'package:easybook_app/features/appointments/presentation/widgets/bookings_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// My Bookings: Upcoming and Past tabs.
class MyBookingsPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<MyBookingsCubit>();
        unawaited(cubit.loadAll());
        return cubit;
      },
      child: const MyBookingsView(),
    );
  }
}

class MyBookingsView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Home's gradient header uses white icons; this page is light.
      value: context.pageOverlayStyle,
      child: DefaultTabController(
        length: BookingsTab.values.length,
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ResponsiveCenter(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.pageTop,
                    AppSpacing.page,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.appointments_title.tr(),
                        style: context.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        LocaleKeys.appointments_subtitle.tr(),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const _SegmentedTabs(),
                    ],
                  ),
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      BookingsList(tab: BookingsTab.upcoming),
                      BookingsList(tab: BookingsTab.past),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented tab switcher: the raised indicator comes from the theme.
class _SegmentedTabs extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: TabBar(
        tabs: [
          Tab(text: LocaleKeys.appointments_tab_upcoming.tr()),
          Tab(text: LocaleKeys.appointments_tab_past.tr()),
        ],
      ),
    );
  }
}
