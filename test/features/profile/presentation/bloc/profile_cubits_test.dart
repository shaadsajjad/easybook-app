import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/features/profile/domain/usecases/change_password.dart';
import 'package:easybook_app/features/profile/domain/usecases/update_profile.dart';
import 'package:easybook_app/features/profile/presentation/bloc/change_password_cubit.dart';
import 'package:easybook_app/features/profile/presentation/bloc/edit_profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_fixtures.dart';

class _MockUpdateProfile extends Mock implements UpdateProfile;

class _MockChangePassword extends Mock implements ChangePassword;

void main() {
  setUpAll(() {
    registerFallbackValue(const UpdateProfileParams(name: ''));
    registerFallbackValue(
      const ChangePasswordParams(currentPassword: '', newPassword: ''),
    );
  });

  group('EditProfileCubit', () {
    late _MockUpdateProfile updateProfile;
    setUp(() => updateProfile = _MockUpdateProfile());

    EditProfileCubit build() => EditProfileCubit(updateProfile: updateProfile);

    blocTest<EditProfileCubit, ProfileFormState>(
      'saves and returns the updated user',
      setUp: () =>
          when(() => updateProfile(any()))
              .thenAnswer((_) async => Right(tRenamedUser)),
      build: build,
      act: (cubit) => cubit.submit(name: 'New Name', phone: '+8801700000000'),
      expect: () => [
        const ProfileFormState(status: FormStatus.submitting),
        ProfileFormState(status: FormStatus.success, user: tRenamedUser),
      ],
      verify: (_) => verify(
        () => updateProfile(
          const UpdateProfileParams(name: 'New Name', phone: '+8801700000000'),
        ),
      ).called(1),
    );

    blocTest<EditProfileCubit, ProfileFormState>(
      'shows a validation failure',
      setUp: () => when(() => updateProfile(any())).thenAnswer(
        (_) async => const Left(
          ValidationFailure(
            'Validation failed',
            fieldErrors: {
              'name': ['Name must be at least 2 characters'],
            },
          ),
        ),
      ),
      build: build,
      act: (cubit) => cubit.submit(name: 'A'),
      verify: (cubit) => expect(
        cubit.state.fieldError('name'),
        'Name must be at least 2 characters',
      ),
    );

    blocTest<EditProfileCubit, ProfileFormState>(
      'ignores a second tap while saving',
      seed: () => const ProfileFormState(status: FormStatus.submitting),
      build: build,
      act: (cubit) => cubit.submit(name: 'A B'),
      expect: () => <ProfileFormState>[],
    );

    blocTest<EditProfileCubit, ProfileFormState>(
      'clearFailure resets the form',
      seed: () => const ProfileFormState(
        status: FormStatus.failure,
        failure: NetworkFailure(),
      ),
      build: build,
      act: (cubit) => cubit.clearFailure(),
      expect: () => [const ProfileFormState()],
    );
  });

  group('ChangePasswordCubit', () {
    late _MockChangePassword changePassword;
    setUp(() => changePassword = _MockChangePassword());

    ChangePasswordCubit build() =>
        ChangePasswordCubit(changePassword: changePassword);

    Future<void> submit(ChangePasswordCubit cubit) =>
        cubit.submit(currentPassword: 'OldPass123', newPassword: 'NewPass456');

    blocTest<ChangePasswordCubit, ProfileFormState>(
      'changes the password',
      setUp: () =>
          when(() => changePassword(any()))
              .thenAnswer((_) async => const Right(unit)),
      build: build,
      act: submit,
      expect: () => [
        const ProfileFormState(status: FormStatus.submitting),
        const ProfileFormState(status: FormStatus.success),
      ],
    );

    blocTest<ChangePasswordCubit, ProfileFormState>(
      'puts a wrong current password under its field',
      setUp: () => when(() => changePassword(any())).thenAnswer(
        (_) async => const Left(
          ValidationFailure(
            'Current password is incorrect',
            fieldErrors: {
              'currentPassword': ['Current password is incorrect'],
            },
          ),
        ),
      ),
      build: build,
      act: submit,
      verify: (cubit) {
        expect(cubit.state.status, FormStatus.failure);
        expect(
          cubit.state.fieldError('currentPassword'),
          'Current password is incorrect',
        );
      },
    );

    blocTest<ChangePasswordCubit, ProfileFormState>(
      'ignores a second tap while saving',
      seed: () => const ProfileFormState(status: FormStatus.submitting),
      build: build,
      act: submit,
      expect: () => <ProfileFormState>[],
    );
  });
}
