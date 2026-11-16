import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/features/auth/domain/usecases/register.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_form_state.dart';
import 'package:easybook_app/features/auth/presentation/bloc/register_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_fixtures.dart';

class _MockRegister extends Mock implements Register;

const _params = RegisterParams(
  name: 'Demo User',
  email: 'demo@example.com',
  password: 'Demo1234',
);

void main() {
  late _MockRegister register;

  setUpAll(() => registerFallbackValue(_params));
  setUp(() => register = _MockRegister());

  RegisterCubit buildCubit() => RegisterCubit(register: register);

  Future<void> submit(RegisterCubit cubit) => cubit.submit(
    name: 'Demo User',
    email: 'demo@example.com',
    password: 'Demo1234',
  );

  blocTest<RegisterCubit, AuthFormState>(
    'emits submitting then success with the new user',
    setUp: () =>
        when(() => register(_params)).thenAnswer((_) async => Right(tUser)),
    build: buildCubit,
    act: submit,
    expect: () => [
      const AuthFormState(status: FormStatus.submitting),
      AuthFormState(status: FormStatus.success, user: tUser),
    ],
  );

  blocTest<RegisterCubit, AuthFormState>(
    'emits a ConflictFailure when the email is taken',
    setUp: () => when(() => register(any())).thenAnswer(
      (_) async => const Left(
        ConflictFailure('An account with this email already exists'),
      ),
    ),
    build: buildCubit,
    act: submit,
    expect: () => [
      const AuthFormState(status: FormStatus.submitting),
      const AuthFormState(
        status: FormStatus.failure,
        failure: ConflictFailure('An account with this email already exists'),
      ),
    ],
  );

  blocTest<RegisterCubit, AuthFormState>(
    'ignores a second submit while the first is in flight',
    seed: () => const AuthFormState(status: FormStatus.submitting),
    build: buildCubit,
    act: submit,
    expect: () => <AuthFormState>[],
  );

  blocTest<RegisterCubit, AuthFormState>(
    'clearFailure resets the form after an error',
    seed: () => const AuthFormState(
      status: FormStatus.failure,
      failure: NetworkFailure(),
    ),
    build: buildCubit,
    act: (cubit) => cubit.clearFailure(),
    expect: () => [const AuthFormState()],
  );
}
