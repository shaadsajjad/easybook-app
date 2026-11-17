import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/aurora_background.dart';
import 'package:easybook_app/core/widgets/fade_slide_in.dart';
import 'package:easybook_app/core/widgets/pressable_scale.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// The aurora hero on top of Home: a greeting for the time of day, the
/// user's initials in a lime ring, and the search bar.
class HomeHeader extends StatelessWidget {
  const new({required this.searchBar, super.key});

  final Widget searchBar;

  static String _greetingKey(int hour) {
    if (hour < 12) return LocaleKeys.services_greeting_morning;
    if (hour < 17) return LocaleKeys.services_greeting_afternoon;
    return LocaleKeys.services_greeting_evening;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final user = context.select<AuthBloc, AuthState>((bloc) => bloc.state).user;
    final greeting = _greetingKey(DateTime.now().hour)
        .tr(namedArgs: {'name': user?.firstName ?? ''});

    return AuroraBackground(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppRadius.xl + AppSpacing.xs),
      ),
      child: SafeArea(
        bottom: false,
        child: ResponsiveCenter(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.pageTop,
            AppSpacing.page,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeSlideIn(
                          child: Text(
                            greeting,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.headlineMedium?.copyWith(
                              color: palette.onHero,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        FadeSlideIn(
                          index: 1,
                          child: Text(
                            LocaleKeys.services_home_subtitle.tr(),
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: palette.onHeroMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  FadeSlideIn(
                    axis: Axis.horizontal,
                    child: _Avatar(initials: user?.initials ?? ''),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(index: 2, child: searchBar),
            ],
          ),
        ),
      ),
    );
  }
}

/// Initials in a lime ring. Tapping it opens the Profile tab.
class _Avatar extends StatelessWidget {
  const new({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: LocaleKeys.nav_profile.tr(),
      child: ExcludeSemantics(
        child: PressableScale(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.go(AppRoutes.profile),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxs + 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: palette.accent,
                  width: AppSizes.borderThick,
                ),
              ),
              child: CircleAvatar(
                radius: AppSizes.avatarSm / 2,
                backgroundColor: palette.heroRaised,
                child: Text(
                  initials,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: palette.accent,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
