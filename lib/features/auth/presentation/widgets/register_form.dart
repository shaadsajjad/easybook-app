import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/utils/validators.dart';
import 'package:easybook_app/core/widgets/app_button.dart';
import 'package:easybook_app/core/widgets/app_text_field.dart';
import 'package:easybook_app/core/widgets/inline_banner.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_form_state.dart';
import 'package:easybook_app/features/auth/presentation/bloc/register_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Name, email, password and confirm password, with the API's rules.
class RegisterForm extends StatefulWidget {
  const new({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    unawaited(
      context.read<RegisterCubit>().submit(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, AuthFormState>(
      builder: (context, state) {
        final cubit = context.read<RegisterCubit>();
        final failure = state.failure;
        return Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: LocaleKeys.auth_name_label.tr(),
                  hint: LocaleKeys.auth_name_hint.tr(),
                  controller: _name,
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: Validators.name,
                  errorText: state.fieldError('name'),
                  onChanged: (_) => cubit.clearFailure(),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: LocaleKeys.auth_email_label.tr(),
                  hint: LocaleKeys.auth_email_hint.tr(),
                  controller: _email,
                  prefixIcon: Icons.mail_outline_rounded,
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
                  hint: LocaleKeys.auth_new_password_hint.tr(),
                  controller: _password,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: Validators.password,
                  errorText: state.fieldError('password'),
                  onChanged: (_) => cubit.clearFailure(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  LocaleKeys.auth_password_rules.tr(),
                  style: context.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: LocaleKeys.auth_confirm_password_label.tr(),
                  hint: LocaleKeys.auth_confirm_password_hint.tr(),
                  controller: _confirm,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    original: _password.text,
                  ),
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (failure != null && failure is! ValidationFailure) ...[
                  const SizedBox(height: AppSpacing.lg),
                  InlineBanner(message: failure.displayMessage),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: LocaleKeys.auth_register_button.tr(),
                  isLoading: state.status.isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
