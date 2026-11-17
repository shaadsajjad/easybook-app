import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/utils/form_status.dart';
import 'package:easybook_app/core/widgets/fade_slide_in.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_form_state.dart';
import 'package:easybook_app/features/auth/presentation/bloc/register_cubit.dart';
import 'package:easybook_app/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:easybook_app/features/auth/presentation/widgets/auth_header.dart';
import 'package:easybook_app/features/auth/presentation/widgets/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterCubit>(),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    // Registering also logs in (the API returns a token), so the user goes
    // straight to Home.
    return BlocListener<RegisterCubit, AuthFormState>(
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
          backgroundColor: context.palette.hero,
          body: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: AuthHeader(
                  title: LocaleKeys.auth_register_title.tr(),
                  subtitle: LocaleKeys.auth_register_subtitle.tr(),
                ),
              ),
              // The form sits on a sheet that slides up over the hero.
              SliverFillRemaining(
                hasScrollBody: false,
                child: FadeSlideIn(
                  index: 2,
                  offset: AppMotion.entranceOffset * 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.xl + AppSpacing.xs),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: ResponsiveCenter(
                        maxWidth: AppBreakpoints.maxFormWidth,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.page,
                          AppSpacing.xl,
                          AppSpacing.page,
                          AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const FadeSlideIn(index: 4, child: RegisterForm()),
                            const SizedBox(height: AppSpacing.md),
                            FadeSlideIn(
                              index: 5,
                              child: AuthFooterLink(
                                question: LocaleKeys.auth_have_account.tr(),
                                action: LocaleKeys.auth_go_login.tr(),
                                onPressed: () => context.go(AppRoutes.login),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
