import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/features/profile/domain/usecases/update_profile.dart';
import 'package:easybook_app/features/profile/presentation/bloc/profile_form_state.dart';

export 'profile_form_state.dart';

class EditProfileCubit extends Cubit<ProfileFormState> {
  new({required this._updateProfile}) : super(const ProfileFormState());

  final UpdateProfile _updateProfile;

  Future<void> submit({required String name, String? phone}) async {
    if (state.status.isSubmitting) return;
    emit(const ProfileFormState(status: FormStatus.submitting));
    final result = await _updateProfile(
      UpdateProfileParams(name: name, phone: phone),
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) =>
            ProfileFormState(status: FormStatus.failure, failure: failure),
        (user) => ProfileFormState(status: FormStatus.success, user: user),
      ),
    );
  }

  void clearFailure() {
    if (state.status == FormStatus.failure) emit(const ProfileFormState());
  }
}
