import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/features/profile/domain/usecases/change_password.dart';
import 'package:easybook_app/features/profile/presentation/bloc/profile_form_state.dart';

export 'profile_form_state.dart';

class ChangePasswordCubit extends Cubit<ProfileFormState> {
  new({required this._changePassword}) : super(const ProfileFormState());

  final ChangePassword _changePassword;

  Future<void> submit({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state.status.isSubmitting) return;
    emit(const ProfileFormState(status: FormStatus.submitting));
    final result = await _changePassword(
      ChangePasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) =>
            ProfileFormState(status: FormStatus.failure, failure: failure),
        (_) => const ProfileFormState(status: FormStatus.success),
      ),
    );
  }

  void clearFailure() {
    if (state.status == FormStatus.failure) emit(const ProfileFormState());
  }
}
