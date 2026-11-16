import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_logo.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/auth/presentation/bloc/splash_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shown while AuthBloc checks the stored token. It also wakes the server.
/// The router leaves this page as soon as AuthBloc knows who the user is.
class SplashPage extends StatelessWidget {
  const new({super.key});

  /// Same size as the glyph on the native launch screen, so the hand-over
  /// from the OS to Flutter looks seamless.
  static const double logoSize = 140;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<SplashCubit>();
        unawaited(cubit.start());
        return cubit;
      },
      child: const SplashView(),
    );
  }
}

class SplashView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final onGradient = context.colors.onPrimary;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: context.palette.brandGradient),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.85, end: 1),
                      duration: AppDurations.slow,
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: const AppLogo(
                        size: SplashPage.logoSize,
                        showBackground: false,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      LocaleKeys.app_name.tr(),
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: onGradient,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      LocaleKeys.app_tagline.tr(),
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: onGradient.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    BlocSelector<AuthBloc, AuthState, Failure?>(
                      selector: (state) => state.failure,
                      builder: (context, failure) => AnimatedSwitcher(
                        duration: AppDurations.medium,
                        child: failure == null
                            ? const _SplashProgress()
                            : _SplashError(failure: failure),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashProgress extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final onGradient = context.colors.onPrimary;
    return Column(
      children: [
        SizedBox.square(
          dimension: AppSizes.iconLg,
          child: CircularProgressIndicator(
            strokeWidth: AppSizes.progressStroke,
            color: onGradient,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        BlocSelector<SplashCubit, SplashState, bool>(
          selector: (state) => state.showWakeUpHint,
          builder: (context, showHint) => AnimatedOpacity(
            opacity: showHint ? 1 : 0,
            duration: AppDurations.medium,
            child: Column(
              children: [
                Text(
                  LocaleKeys.splash_waking_up.tr(),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: onGradient,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  LocaleKeys.splash_waking_up_hint.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: onGradient.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashError extends StatelessWidget {
  const new({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final onGradient = context.colors.onPrimary;
    return Column(
      children: [
        Text(
          LocaleKeys.splash_error_title.tr(),
          style: context.textTheme.titleMedium?.copyWith(color: onGradient),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          failure.displayMessage,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: onGradient.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () =>
              context.read<AuthBloc>().add(const AuthSessionRequested()),
          style: FilledButton.styleFrom(
            backgroundColor: onGradient,
            foregroundColor: context.colors.primary,
            minimumSize: const Size(0, AppSizes.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(LocaleKeys.common_retry.tr()),
        ),
      ],
    );
  }
}
