import 'package:equatable/equatable.dart';

/// A bookable service, for example "Classic Haircut".
class Service extends Equatable {
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

  final String id;
  final String name;
  final String description;

  /// In BDT. The API sends it as a string ("500.00"); the model parses it.
  final double price;
  final int durationMinutes;
  final String imageUrl;
  final String category;
  final bool isFeatured;

  @override
  List<Object> get props => [
    id,
    name,
    description,
    price,
    durationMinutes,
    imageUrl,
    category,
    isFeatured,
  ];
}
