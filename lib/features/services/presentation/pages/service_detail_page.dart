import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/empty_view.dart';
import 'package:easybook_app/core/widgets/error_view.dart';
import 'package:easybook_app/core/widgets/loading_view.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/presentation/bloc/service_detail_cubit.dart';
import 'package:easybook_app/features/services/presentation/widgets/book_now_bar.dart';
import 'package:easybook_app/features/services/presentation/widgets/service_detail_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Full details of one service, with a sticky "Book now" bar.
class ServiceDetailPage extends StatelessWidget {
  const new({required this.serviceId, this.initial, super.key});

  final String serviceId;

  /// The service tapped in the list, shown while the fresh copy loads.
  final Service? initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<ServiceDetailCubit>();
        unawaited(cubit.load(serviceId, initial: initial));
        return cubit;
      },
      child: ServiceDetailView(serviceId: serviceId),
    );
  }
}

class ServiceDetailView extends StatelessWidget {
  const new({required this.serviceId, super.key});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceDetailCubit, ServiceDetailState>(
      builder: (context, state) {
        final service = state.service;
        if (service != null) {
          return Scaffold(
            body: ServiceDetailContent(service: service),
            bottomNavigationBar: BookNowBar(
              price: service.price,
              onBook: () => context.push(
                AppRoutes.bookServicePath(service.id),
                extra: service,
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: switch (state.status) {
            ServiceDetailStatus.failure => _DetailError(
              failure: state.failure,
              onRetry: () => context.read<ServiceDetailCubit>().load(serviceId),
            ),
            _ => const LoadingView(),
          },
        );
      },
    );
  }
}

class _DetailError extends StatelessWidget {
  const new({required this.failure, required this.onRetry});

  final Failure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (failure is NotFoundFailure) {
      return EmptyView(
        icon: AppIcons.noResults,
        title: LocaleKeys.services_not_found_title.tr(),
        message: LocaleKeys.services_not_found_message.tr(),
        actionLabel: LocaleKeys.services_back_home.tr(),
        onAction: () => context.go(AppRoutes.home),
      );
    }
    return ErrorView(message: failure?.displayMessage ?? '', onRetry: onRetry);
  }
}
