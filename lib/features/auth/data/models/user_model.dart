import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// The `User` JSON from the API (see docs/API.md, Data models).
@JsonSerializable()
class UserModel {
  const new({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.phone,
  });

  factory fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() => User(
    id: id,
    name: name,
    email: email,
    phone: phone,
    createdAt: createdAt,
  );
}
