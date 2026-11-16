import 'package:equatable/equatable.dart';

/// The short service info included in every appointment.
class ServiceSummary extends Equatable {
  const new({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    required this.imageUrl,
    required this.category,
  });

  final String id;
  final String name;
  final double price;
  final int durationMinutes;
  final String imageUrl;
  final String category;

  @override
  List<Object> get props => [
    id,
    name,
    price,
    durationMinutes,
    imageUrl,
    category,
  ];
}
