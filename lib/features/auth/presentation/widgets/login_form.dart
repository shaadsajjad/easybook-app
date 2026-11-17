import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/utils/validators.dart';
import 'package:easybook_app/core/widgets/app_button.dart';
import 'package:easybook_app/core/widgets/app_text_field.dart';
import 'package:easybook_app/core/widgets/inline_banner.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/auth/presentation/bloc/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Email + password form. Client-side rules run first; server errors
/// (wrong password, 422 field errors, no connection) appear after submit.
class LoginForm extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    unawaited(
      context.read<LoginCubit>().submit(
        email: _email.text,
        password: _password.text,
      ),
    );
  }

  void _useDemoAccount() {
    _email.text = AppConstants.demoEmail;
    _password.text = AppConstants.demoPassword;
    context.read<LoginCubit>().clearFailure();
  }

  @override
  Widget build(BuildContext context) {
    final sessionExpired = context.select<AuthBloc, bool>(
      (bloc) => bloc.state.sessionExpired,
    );
    return BlocBuilder<LoginCubit, AuthFormState>(
      builder: (context, state) {
        final cubit = context.read<LoginCubit>();
        final failure = state.failure;
        return Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (sessionExpired && failure == null) ...[
                  InlineBanner(
                    message: LocaleKeys.auth_session_expired.tr(),
                    tone: InlineBannerTone.info,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                AppTextField(
                  label: LocaleKeys.auth_email_label.tr(),
                  hint: LocaleKeys.auth_email_hint.tr(),
                  controller: _email,
                  prefixIcon: AppIcons.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                  errorText: state.fieldError('email'),
                  onChanged: (_) => cubit.clearFailure(),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: LocaleKeys.auth_password_label.tr(),
                  hint: LocaleKeys.auth_password_hint.tr(),
                  controller: _password,
                  prefixIcon: AppIcons.password,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: Validators.requiredPassword,
                  errorText: state.fieldError('password'),
                  onChanged: (_) => cubit.clearFailure(),
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (failure != null && failure is! ValidationFailure) ...[
                  const SizedBox(height: AppSpacing.lg),
                  InlineBanner(message: failure.displayMessage),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: LocaleKeys.auth_login_button.tr(),
                  isLoading: state.status.isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: LocaleKeys.auth_demo_button.tr(),
                  icon: AppIcons.demo,
                  variant: AppButtonVariant.secondary,
                  onPressed: state.status.isSubmitting ? null : _useDemoAccount,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
