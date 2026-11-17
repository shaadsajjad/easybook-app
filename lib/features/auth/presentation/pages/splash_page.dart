import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/app_logo.dart';
import 'package:easybook_app/core/widgets/aurora_background.dart';
import 'package:easybook_app/core/widgets/fade_slide_in.dart';
import 'package:easybook_app/core/widgets/pulse_rings.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/auth/presentation/bloc/splash_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shown while AuthBloc checks the stored token. It also wakes the server.
/// The router leaves this page as soon as AuthBloc knows who the user is.
class SplashPage extends StatelessWidget {
  const new({super.key});

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
    final onGradient = context.palette.onHero;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // Ink, like the native launch screen, with the aurora drifting in.
        body: AuroraBackground(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    // The logo builds itself (page, rings, check) inside
                    // radar-like pulse rings.
                    PulseRings(
                      color: context.palette.accent,
                      size: AppSizes.splashLogo,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : AppDurations.logo,
                        builder: (context, t, _) => AppLogo(
                          size: AppSizes.splashLogo,
                          showBackground: false,
                          progress: t,
                        ),
                      ),
                    ),
                    FadeSlideIn(
                      index: 6,
                      child: Text(
                        LocaleKeys.app_name.tr(),
                        style: context.textTheme.displaySmall?.copyWith(
                          color: onGradient,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FadeSlideIn(
                      index: 7,
                      child: Text(
                        LocaleKeys.app_tagline.tr(),
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: onGradient.withValues(alpha: 0.8),
                        ),
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
    final onGradient = context.palette.onHero;
    return Column(
      children: [
        SizedBox.square(
          dimension: AppSizes.iconLg,
          child: CircularProgressIndicator(
            strokeWidth: AppSizes.progressStroke,
            color: context.palette.accent,
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
    final onGradient = context.palette.onHero;
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
            backgroundColor: context.palette.solidFill,
            foregroundColor: context.palette.onSolidFill,
            minimumSize: const Size(0, AppSizes.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          ),
          icon: const Icon(AppIcons.retry),
          label: Text(LocaleKeys.common_retry.tr()),
        ),
      ],
    );
  }
}
