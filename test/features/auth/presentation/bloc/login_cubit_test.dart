import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/features/auth/domain/usecases/login.dart';
import 'package:easybook_app/features/auth/presentation/bloc/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_fixtures.dart';

class _MockLogin extends Mock implements Login;

const _params = LoginParams(email: 'demo@example.com', password: 'Demo1234');

void main() {
  late _MockLogin login;

  setUpAll(() => registerFallbackValue(_params));
  setUp(() => login = _MockLogin());

  LoginCubit buildCubit() => LoginCubit(login: login);

  blocTest<LoginCubit, AuthFormState>(
    'emits submitting then success with the user',
    setUp: () =>
        when(() => login(_params)).thenAnswer((_) async => Right(tUser)),
    build: buildCubit,
    act: (cubit) =>
        cubit.submit(email: 'demo@example.com', password: 'Demo1234'),
    expect: () => [
      const AuthFormState(status: FormStatus.submitting),
      AuthFormState(status: FormStatus.success, user: tUser),
    ],
  );

  blocTest<LoginCubit, AuthFormState>(
    'emits the failure for wrong credentials',
    setUp: () => when(() => login(any())).thenAnswer(
      (_) async => const Left(UnauthorizedFailure('Invalid email or password')),
    ),
    build: buildCubit,
    act: (cubit) => cubit.submit(email: 'a@b.co', password: 'wrong'),
    expect: () => [
      const AuthFormState(status: FormStatus.submitting),
      const AuthFormState(
        status: FormStatus.failure,
        failure: UnauthorizedFailure('Invalid email or password'),
      ),
    ],
  );

  blocTest<LoginCubit, AuthFormState>(
    'ignores a second submit while the first is in flight',
    seed: () => const AuthFormState(status: FormStatus.submitting),
    build: buildCubit,
    act: (cubit) => cubit.submit(email: 'a@b.co', password: 'x'),
    expect: () => <AuthFormState>[],
    verify: (_) => verifyNever(() => login(any())),
  );

  blocTest<LoginCubit, AuthFormState>(
    'clearFailure resets the form after an error',
    seed: () => const AuthFormState(
      status: FormStatus.failure,
      failure: NetworkFailure(),
    ),
    build: buildCubit,
    act: (cubit) => cubit.clearFailure(),
    expect: () => [const AuthFormState()],
  );

  test('fieldError reads 422 messages by field', () {
    const state = AuthFormState(
      status: FormStatus.failure,
      failure: ValidationFailure(
        'Validation failed',
        fieldErrors: {
          'email': ['Enter a valid email address'],
        },
      ),
    );
    expect(state.fieldError('email'), 'Enter a valid email address');
    expect(state.fieldError('password'), isNull);
    expect(const AuthFormState().fieldError('email'), isNull);
  });
}
