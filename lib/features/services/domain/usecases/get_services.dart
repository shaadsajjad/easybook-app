import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/domain/entities/service_filter.dart';
import 'package:easybook_app/features/services/domain/entities/services_page.dart';
import 'package:easybook_app/features/services/domain/repositories/services_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

class GetServicesParams extends Equatable {
  const new({required this.filter, this.page = 1});

  final ServiceFilter filter;
  final int page;

  @override
  List<Object> get props => [filter, page];
}

class GetServices {
  const new(this._repository);

  final ServicesRepository _repository;

  Future<Either<Failure, ServicesPage>> call(GetServicesParams params) =>
      _repository.getServices(filter: params.filter, page: params.page);
}
