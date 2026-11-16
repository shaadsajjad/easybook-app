import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/auth/presentation/bloc/login_cubit.dart';
import 'package:easybook_app/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:easybook_app/features/auth/presentation/widgets/auth_header.dart';
import 'package:easybook_app/features/auth/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginCubit>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    // On success, hand the user to AuthBloc; the router then opens Home.
    return BlocListener<LoginCubit, AuthFormState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == FormStatus.success,
      listener: (context, state) {
        final user = state.user;
        if (user != null) context.read<AuthBloc>().add(AuthLoggedIn(user));
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                AuthHeader(
                  title: LocaleKeys.auth_login_title.tr(),
                  subtitle: LocaleKeys.auth_login_subtitle.tr(),
                ),
                SafeArea(
                  top: false,
                  child: ResponsiveCenter(
                    maxWidth: AppBreakpoints.maxFormWidth,
                    padding: const EdgeInsets.all(AppSpacing.page),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        const LoginForm(),
                        const SizedBox(height: AppSpacing.lg),
                        AuthFooterLink(
                          question: LocaleKeys.auth_no_account.tr(),
                          action: LocaleKeys.auth_go_register.tr(),
                          onPressed: () => context.go(AppRoutes.register),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
