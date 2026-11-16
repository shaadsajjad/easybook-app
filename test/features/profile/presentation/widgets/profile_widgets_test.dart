import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/profile/presentation/bloc/change_password_cubit.dart';
import 'package:easybook_app/features/profile/presentation/bloc/edit_profile_cubit.dart';
import 'package:easybook_app/features/profile/presentation/pages/change_password_page.dart';
import 'package:easybook_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:easybook_app/features/profile/presentation/pages/profile_page.dart';
import 'package:easybook_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_fixtures.dart';
import '../../../../helpers/helpers.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc;

class _MockEditCubit extends MockCubit<ProfileFormState>
    implements EditProfileCubit;

class _MockPasswordCubit extends MockCubit<ProfileFormState>
    implements ChangePasswordCubit;

void main() {
  late _MockAuthBloc authBloc;

  setUpAll(() => registerFallbackValue(const AuthLogoutRequested()));

  setUp(() {
    authBloc = _MockAuthBloc();
    when(() => authBloc.state).thenReturn(AuthState.authenticated(tUser));
  });

  testWidgets('ProfileHeader shows the name, email and phone', (tester) async {
    await tester.pumpApp(ProfileHeader(user: tUser));

    expect(find.text('Demo User'), findsOneWidget);
    expect(find.text('demo@example.com'), findsOneWidget);
    expect(find.text('+8801700000000'), findsOneWidget);
    expect(find.text('DU'), findsOneWidget);
  });

  testWidgets('ProfileHeader says when there is no phone', (tester) async {
    await tester.pumpApp(ProfileHeader(user: tRenamedUserWithoutPhone));
    expect(find.text(LocaleKeys.profile_no_phone), findsOneWidget);
  });

  testWidgets('logging out asks first, then tells AuthBloc', (tester) async {
    // A tall screen, so the whole profile menu is visible.
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(800, 1600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const ProfilePage(),
        ),
      ),
    );

    await tester.tap(find.text(LocaleKeys.auth_logout));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(LocaleKeys.auth_logout_confirm_title), findsOneWidget);

    await tester.tap(find.text(LocaleKeys.auth_logout).last);
    await tester.pump(const Duration(milliseconds: 500));
    verify(() => authBloc.add(const AuthLogoutRequested())).called(1);
  });

  group('EditProfileForm', () {
    late _MockEditCubit cubit;

    setUp(() {
      cubit = _MockEditCubit();
      when(() => cubit.state).thenReturn(const ProfileFormState());
      when(
        () => cubit.submit(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
        ),
      ).thenAnswer((_) async {});
    });

    Future<void> pump(WidgetTester tester) => tester.pumpApp(
      BlocProvider<EditProfileCubit>.value(
        value: cubit,
        child: EditProfileForm(user: tUser),
      ),
    );

    testWidgets('fills in the profile and locks the email', (tester) async {
      await pump(tester);

      expect(find.text('Demo User'), findsOneWidget);
      expect(find.text('+8801700000000'), findsOneWidget);
      final email = tester.widget<TextField>(
        find.widgetWithText(TextField, 'demo@example.com'),
      );
      expect(email.enabled, isFalse);
      expect(find.text(LocaleKeys.profile_email_locked), findsOneWidget);
    });

    testWidgets('does not save an invalid name', (tester) async {
      await pump(tester);

      await tester.enterText(find.widgetWithText(TextField, 'Demo User'), 'A');
      await tester.tap(find.text(LocaleKeys.profile_save));
      await tester.pump();

      expect(find.text(LocaleKeys.validation_name_min), findsOneWidget);
      verifyNever(
        () => cubit.submit(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
        ),
      );
    });

    testWidgets('saves the name and phone', (tester) async {
      await pump(tester);

      await tester.tap(find.text(LocaleKeys.profile_save));
      await tester.pump();

      verify(() => cubit.submit(name: 'Demo User', phone: '+8801700000000'))
          .called(1);
    });
  });

  group('ChangePasswordForm', () {
    late _MockPasswordCubit cubit;

    setUp(() {
      cubit = _MockPasswordCubit();
      when(() => cubit.state).thenReturn(const ProfileFormState());
      when(
        () => cubit.submit(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async {});
    });

    Future<void> pump(WidgetTester tester) => tester.pumpApp(
      BlocProvider<ChangePasswordCubit>.value(
        value: cubit,
        child: const ChangePasswordForm(),
      ),
    );

    Future<void> fill(
      WidgetTester tester, {
      required String current,
      required String newPassword,
      required String confirm,
    }) async {
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), current);
      await tester.enterText(fields.at(1), newPassword);
      await tester.enterText(fields.at(2), confirm);
      await tester.tap(find.text(LocaleKeys.profile_update_password));
      await tester.pump();
    }

    testWidgets('requires the confirmation to match', (tester) async {
      await pump(tester);
      await fill(
        tester,
        current: 'OldPass123',
        newPassword: 'NewPass456',
        confirm: 'NewPass457',
      );

      expect(
        find.text(LocaleKeys.validation_password_mismatch),
        findsOneWidget,
      );
      verifyNever(
        () => cubit.submit(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    testWidgets('the new password must differ from the current one', (
      tester,
    ) async {
      await pump(tester);
      await fill(
        tester,
        current: 'Same1234',
        newPassword: 'Same1234',
        confirm: 'Same1234',
      );

      expect(find.text(LocaleKeys.validation_password_same), findsOneWidget);
    });

    testWidgets('sends a valid change', (tester) async {
      await pump(tester);
      await fill(
        tester,
        current: 'OldPass123',
        newPassword: 'NewPass456',
        confirm: 'NewPass456',
      );

      verify(
        () => cubit.submit(
          currentPassword: 'OldPass123',
          newPassword: 'NewPass456',
        ),
      ).called(1);
    });

    testWidgets('shows a wrong current password under that field', (
      tester,
    ) async {
      when(() => cubit.state).thenReturn(
        const ProfileFormState(
          status: FormStatus.failure,
          failure: ValidationFailure(
            'Current password is incorrect',
            fieldErrors: {
              'currentPassword': ['Current password is incorrect'],
            },
          ),
        ),
      );
      await pump(tester);

      expect(find.text('Current password is incorrect'), findsOneWidget);
    });
  });
}
