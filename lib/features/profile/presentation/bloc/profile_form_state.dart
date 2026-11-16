import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

/// State of the edit-profile and change-password forms.
class ProfileFormState extends Equatable {
  const new({this.status = FormStatus.initial, this.user, this.failure});

  final FormStatus status;

  /// The updated profile (edit profile only).
  final User? user;
  final Failure? failure;

  /// A 422 message for [field], shown under that field.
  String? fieldError(String field) => switch (failure) {
    ValidationFailure(:final errorFor) => errorFor(field),
    _ => null,
  };

  @override
  List<Object?> get props => [status, user, failure];
}
