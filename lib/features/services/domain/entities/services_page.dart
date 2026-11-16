import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:equatable/equatable.dart';

/// One page of `GET /services` plus its pagination info.
class ServicesPage extends Equatable {
  const new({
    required this.services,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  final List<Service> services;
  final int page;
  final int totalPages;
  final int total;

  bool get hasMore => page < totalPages;

  @override
  List<Object> get props => [services, page, totalPages, total];
}
