import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/domain/usecases/get_featured_services.dart';
import 'package:equatable/equatable.dart';

enum FeaturedStatus { initial, loading, success, failure }

class FeaturedServicesState extends Equatable {
  const new({
    this.status = FeaturedStatus.initial,
    this.services = const [],
    this.failure,
  });

  final FeaturedStatus status;
  final List<Service> services;
  final Failure? failure;

  @override
  List<Object?> get props => [status, services, failure];
}

/// The featured carousel on Home.
class FeaturedServicesCubit extends Cubit<FeaturedServicesState> {
  new({required this._getFeaturedServices})
    : super(const FeaturedServicesState());

  final GetFeaturedServices _getFeaturedServices;

  Future<void> load() async {
    emit(
      FeaturedServicesState(
        status: FeaturedStatus.loading,
        services: state.services,
      ),
    );
    final result = await _getFeaturedServices();
    emit(
      result.fold(
        (failure) => FeaturedServicesState(
          status: FeaturedStatus.failure,
          failure: failure,
        ),
        (services) => FeaturedServicesState(
          status: FeaturedStatus.success,
          services: services,
        ),
      ),
    );
  }
}
