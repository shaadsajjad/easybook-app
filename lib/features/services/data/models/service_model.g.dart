// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) => ServiceModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: _parsePrice(json['price'] as String),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  imageUrl: json['imageUrl'] as String,
  category: json['category'] as String,
  isFeatured: json['isFeatured'] as bool,
);
