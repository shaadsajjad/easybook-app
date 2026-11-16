import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/core/utils/validators.dart';
import 'package:easybook_app/core/widgets/app_button.dart';
import 'package:easybook_app/core/widgets/app_text_field.dart';
import 'package:easybook_app/core/widgets/inline_banner.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/profile/presentation/bloc/change_password_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Current, new and confirm-new password. The user stays logged in.
class ChangePasswordPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChangePasswordCubit>(),
      child: Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.profile_change_password.tr())),
        body: const ChangePasswordForm(),
      ),
    );
  }
}

class ChangePasswordForm extends StatefulWidget {
  const new({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    unawaited(
      context.read<ChangePasswordCubit>().submit(
        currentPassword: _current.text,
        newPassword: _new.text,
      ),
    );
  }

  void _onChanged(BuildContext context, ProfileFormState state) {
    _current.clear();
    _new.clear();
    _confirm.clear();
    context.showSnackBar(LocaleKeys.profile_password_changed.tr());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordCubit, ProfileFormState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == FormStatus.success,
      listener: _onChanged,
      builder: (context, state) {
        final cubit = context.read<ChangePasswordCubit>();
        final failure = state.failure;
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ResponsiveCenter(
            maxWidth: AppBreakpoints.maxFormWidth,
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: LocaleKeys.profile_current_password_label.tr(),
                      hint: LocaleKeys.profile_current_password_hint.tr(),
                      controller: _current,
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.password],
                      validator: Validators.requiredPassword,
                      // "Current password is incorrect" arrives as a 422
                      // on this field.
                      errorText: state.fieldError('currentPassword'),
                      onChanged: (_) => cubit.clearFailure(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: LocaleKeys.profile_new_password_label.tr(),
                      hint: LocaleKeys.profile_new_password_hint.tr(),
                      controller: _new,
                      prefixIcon: Icons.key_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: (value) =>
                          Validators.newPassword(value, current: _current.text),
                      errorText: state.fieldError('newPassword'),
                      onChanged: (_) => cubit.clearFailure(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      LocaleKeys.profile_password_rules.tr(),
                      style: context.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: LocaleKeys.profile_confirm_password_label.tr(),
                      hint: LocaleKeys.profile_confirm_password_hint.tr(),
                      controller: _confirm,
                      prefixIcon: Icons.key_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) => Validators.confirmPassword(
                        value,
                        original: _new.text,
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (failure != null &&
                        (failure is! ValidationFailure ||
                            failure.fieldErrors.isEmpty)) ...[
                      const SizedBox(height: AppSpacing.lg),
                      InlineBanner(message: failure.displayMessage),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: LocaleKeys.profile_update_password.tr(),
                      isLoading: state.status.isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
