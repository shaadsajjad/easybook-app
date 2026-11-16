import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/features/auth/domain/usecases/login.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_form_state.dart';

export 'auth_form_state.dart';

class LoginCubit extends Cubit<AuthFormState> {
  new({required this._login}) : super(const AuthFormState());

  final Login _login;

  Future<void> submit({required String email, required String password}) async {
    // Ignore double taps while a request is in flight.
    if (state.status.isSubmitting) return;
    emit(const AuthFormState(status: FormStatus.submitting));

    final result = await _login(LoginParams(email: email, password: password));
    emit(
      result.fold(
        (failure) =>
            AuthFormState(status: FormStatus.failure, failure: failure),
        (user) => AuthFormState(status: FormStatus.success, user: user),
      ),
    );
  }

  /// Hides a server error once the user edits a field again.
  void clearFailure() {
    if (state.status == FormStatus.failure) emit(const AuthFormState());
  }
}
