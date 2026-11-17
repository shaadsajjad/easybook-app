import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/core/utils/validators.dart';
import 'package:easybook_app/core/widgets/app_button.dart';
import 'package:easybook_app/core/widgets/app_text_field.dart';
import 'package:easybook_app/core/widgets/inline_banner.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/profile/presentation/bloc/edit_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Edit name and phone. The email is shown but locked.
class EditProfilePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;
    return BlocProvider(
      create: (_) => getIt<EditProfileCubit>(),
      child: Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.profile_edit_profile.tr())),
        // Only reachable while logged in, so user is always set here.
        body: user == null
            ? const SizedBox.shrink()
            : EditProfileForm(user: user),
      ),
    );
  }
}

class EditProfileForm extends StatefulWidget {
  const new({required this.user, super.key});

  final User user;

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user.name);
  late final _phone = TextEditingController(text: widget.user.phone ?? '');
  late final _email = TextEditingController(text: widget.user.email);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    unawaited(
      context.read<EditProfileCubit>().submit(
        name: _name.text,
        phone: _phone.text,
      ),
    );
  }

  void _onSaved(BuildContext context, ProfileFormState state) {
    final user = state.user;
    if (user == null) return;
    // AuthBloc holds the user for the whole app (Home greeting, Profile).
    context.read<AuthBloc>().add(AuthUserUpdated(user));
    context.showSnackBar(LocaleKeys.profile_profile_updated.tr());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, ProfileFormState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == FormStatus.success,
      listener: _onSaved,
      builder: (context, state) {
        final cubit = context.read<EditProfileCubit>();
        final failure = state.failure;
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ResponsiveCenter(
            maxWidth: AppBreakpoints.maxFormWidth,
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: LocaleKeys.profile_name_label.tr(),
                    controller: _name,
                    prefixIcon: AppIcons.person,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: Validators.name,
                    errorText: state.fieldError('name'),
                    onChanged: (_) => cubit.clearFailure(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: LocaleKeys.profile_email_label.tr(),
                    controller: _email,
                    prefixIcon: AppIcons.password,
                    readOnly: true,
                    enabled: false,
                    helperText: LocaleKeys.profile_email_locked.tr(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: LocaleKeys.profile_phone_label.tr(),
                    hint: LocaleKeys.profile_phone_hint.tr(),
                    controller: _phone,
                    prefixIcon: AppIcons.phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    validator: Validators.phone,
                    errorText: state.fieldError('phone'),
                    onChanged: (_) => cubit.clearFailure(),
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
                    label: LocaleKeys.profile_save.tr(),
                    isLoading: state.status.isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
