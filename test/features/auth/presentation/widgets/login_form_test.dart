import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/auth/presentation/bloc/login_cubit.dart';
import 'package:easybook_app/features/auth/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

class _MockLoginCubit extends MockCubit<AuthFormState> implements LoginCubit;

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc;

void main() {
  late _MockLoginCubit cubit;
  late _MockAuthBloc authBloc;

  setUp(() {
    cubit = _MockLoginCubit();
    authBloc = _MockAuthBloc();
    when(() => cubit.state).thenReturn(const AuthFormState());
    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    when(
      () => cubit.submit(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> pumpForm(WidgetTester tester) => tester.pumpApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>.value(value: cubit),
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: const SingleChildScrollView(child: LoginForm()),
    ),
  );

  testWidgets('shows field errors and does not submit an empty form', (
    tester,
  ) async {
    await pumpForm(tester);

    await tester.tap(find.text(LocaleKeys.auth_login_button));
    await tester.pump();

    expect(find.text(LocaleKeys.validation_email_required), findsOneWidget);
    expect(find.text(LocaleKeys.validation_password_required), findsOneWidget);
    verifyNever(
      () => cubit.submit(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('the demo button fills the form and submit sends it', (
    tester,
  ) async {
    when(() => cubit.clearFailure()).thenReturn(null);
    await pumpForm(tester);

    await tester.tap(find.text(LocaleKeys.auth_demo_button));
    await tester.pump();
    await tester.tap(find.text(LocaleKeys.auth_login_button));
    await tester.pump();

    verify(
      () => cubit.submit(
        email: AppConstants.demoEmail,
        password: AppConstants.demoPassword,
      ),
    ).called(1);
  });

  testWidgets('shows the server message for wrong credentials', (tester) async {
    when(() => cubit.state).thenReturn(
      const AuthFormState(
        status: FormStatus.failure,
        failure: UnauthorizedFailure('Invalid email or password'),
      ),
    );
    await pumpForm(tester);

    expect(find.text('Invalid email or password'), findsOneWidget);
  });

  testWidgets('shows a 422 message under its field', (tester) async {
    when(() => cubit.state).thenReturn(
      const AuthFormState(
        status: FormStatus.failure,
        failure: ValidationFailure(
          'Validation failed',
          fieldErrors: {
            'email': ['Enter a valid email address'],
          },
        ),
      ),
    );
    await pumpForm(tester);

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Validation failed'), findsNothing);
  });

  testWidgets('shows a spinner while submitting', (tester) async {
    when(() => cubit.state)
        .thenReturn(const AuthFormState(status: FormStatus.submitting));
    await pumpForm(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(LocaleKeys.auth_login_button), findsNothing);
  });

  testWidgets('explains an expired session', (tester) async {
    when(() => authBloc.state)
        .thenReturn(const AuthState.unauthenticated(sessionExpired: true));
    await pumpForm(tester);

    expect(find.text(LocaleKeys.auth_session_expired), findsOneWidget);
  });
}
