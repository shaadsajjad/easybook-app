import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

/// State of the login and register forms.
class AuthFormState extends Equatable {
  const new({this.status = FormStatus.initial, this.user, this.failure});

  final FormStatus status;

  /// Set on success; the page hands it to AuthBloc.
  final User? user;
  final Failure? failure;

  /// Field messages from a 422, shown under the matching field.
  String? fieldError(String field) => switch (failure) {
    ValidationFailure(:final errorFor) => errorFor(field),
    _ => null,
  };

  @override
  List<Object?> get props => [status, user, failure];
}
