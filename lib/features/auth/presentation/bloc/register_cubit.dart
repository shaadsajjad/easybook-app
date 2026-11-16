import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/features/auth/domain/usecases/register.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_form_state.dart';

/// Creates an account. Shares [AuthFormState] with LoginCubit.
class RegisterCubit extends Cubit<AuthFormState> {
  new({required this._register}) : super(const AuthFormState());

  final Register _register;

  Future<void> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.status.isSubmitting) return;
    emit(const AuthFormState(status: FormStatus.submitting));

    final result = await _register(
      RegisterParams(name: name, email: email, password: password),
    );
    emit(
      result.fold(
        (failure) =>
            AuthFormState(status: FormStatus.failure, failure: failure),
        (user) => AuthFormState(status: FormStatus.success, user: user),
      ),
    );
  }

  void clearFailure() {
    if (state.status == FormStatus.failure) emit(const AuthFormState());
  }
}
