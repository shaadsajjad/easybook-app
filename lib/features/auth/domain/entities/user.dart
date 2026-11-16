import 'package:equatable/equatable.dart';

/// The logged-in customer.
class User extends Equatable {
  const new({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.phone,
  });

  final String id;
  final String name;

  /// Always lowercase. Cannot be changed.
  final String email;

  /// Null until the user adds one.
  final String? phone;
  final DateTime createdAt;

  /// "Ayesha Rahman" -> "AR", for the avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts.where((part) => part.isNotEmpty).take(2);
    return letters.map((part) => part[0].toUpperCase()).join();
  }

  /// "Ayesha Rahman" -> "Ayesha", for greetings.
  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  @override
  List<Object?> get props => [id, name, email, phone, createdAt];
}
