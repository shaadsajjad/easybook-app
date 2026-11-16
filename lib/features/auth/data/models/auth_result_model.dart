import 'package:easybook_app/features/auth/data/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_result_model.g.dart';

/// `data` of register and login: `{ user, token }`.
/// The token never leaves the data layer; it goes straight to storage.
@JsonSerializable(createToJson: false)
class AuthResultModel {
  const new({required this.user, required this.token});

  factory fromJson(Map<String, dynamic> json) =>
      _$AuthResultModelFromJson(json);

  final UserModel user;
  final String token;
}
