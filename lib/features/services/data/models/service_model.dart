import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service_model.g.dart';

/// The `Service` JSON from the API. Dates are not needed by the app, so
/// they are not read.
@JsonSerializable(createToJson: false)
class ServiceModel {
  const new({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.imageUrl,
    required this.category,
    required this.isFeatured,
  });

  factory fromJson(Map<String, dynamic> json) => _$ServiceModelFromJson(json);

  final String id;
  final String name;
  final String description;

  /// "500.00" in the JSON, 500.0 here.
  @JsonKey(fromJson: _parsePrice)
  final double price;
  final int durationMinutes;
  final String imageUrl;
  final String category;
  final bool isFeatured;

  Service toEntity() => Service(
    id: id,
    name: name,
    description: description,
    price: price,
    durationMinutes: durationMinutes,
    imageUrl: imageUrl,
    category: category,
    isFeatured: isFeatured,
  );
}

double _parsePrice(String value) => double.parse(value);
