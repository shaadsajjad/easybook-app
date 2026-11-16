import 'package:json_annotation/json_annotation.dart';

part 'pagination_meta_model.g.dart';

/// `meta` of `GET /services`: `{ page, limit, total, totalPages }`.
@JsonSerializable(createToJson: false)
class PaginationMetaModel {
  const new({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaModelFromJson(json);

  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
