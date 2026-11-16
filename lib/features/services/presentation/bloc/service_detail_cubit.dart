import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/domain/usecases/get_service_by_id.dart';
import 'package:equatable/equatable.dart';

enum ServiceDetailStatus { initial, loading, success, failure }

class ServiceDetailState extends Equatable {
  const new({
    this.status = ServiceDetailStatus.initial,
    this.service,
    this.failure,
  });

  final ServiceDetailStatus status;
  final Service? service;
  final Failure? failure;

  @override
  List<Object?> get props => [status, service, failure];
}

/// One service, loaded by id.
///
/// When the list passes the tapped service along ([load]'s `initial`), it
/// is shown right away and refreshed from the API in the background.
class ServiceDetailCubit extends Cubit<ServiceDetailState> {
  new({required this._getServiceById}) : super(const ServiceDetailState());

  final GetServiceById _getServiceById;

  Future<void> load(String id, {Service? initial}) async {
    emit(
      initial == null
          ? const ServiceDetailState(status: ServiceDetailStatus.loading)
          : ServiceDetailState(
              status: ServiceDetailStatus.success,
              service: initial,
            ),
    );

    final result = await _getServiceById(id);
    final shown = state.service;
    emit(
      result.fold(
        (failure) =>
            // Keep the optimistic copy unless the service is really gone.
            shown != null && failure is! NotFoundFailure
            ? state
            : ServiceDetailState(
                status: ServiceDetailStatus.failure,
                failure: failure,
              ),
        (service) => ServiceDetailState(
          status: ServiceDetailStatus.success,
          service: service,
        ),
      ),
    );
  }
}
