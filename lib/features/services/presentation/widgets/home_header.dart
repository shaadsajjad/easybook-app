import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Gradient top of Home: a greeting for the time of day, the user's
/// initials and the search bar.
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
    final user = context.select<AuthBloc, AuthState>((bloc) => bloc.state).user;
    final onGradient = context.colors.onPrimary;
    final greeting = _greetingKey(DateTime.now().hour)
        .tr(namedArgs: {'name': user?.firstName ?? ''});

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: context.palette.brandGradient,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ResponsiveCenter(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.headlineSmall?.copyWith(
                            color: onGradient,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          LocaleKeys.services_home_subtitle.tr(),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: onGradient.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  CircleAvatar(
                    radius: AppSizes.avatar / 2.4,
                    backgroundColor: context.palette.solidFill,
                    child: Text(
                      user?.initials ?? '',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: onGradient,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              searchBar,
            ],
          ),
        ),
      ),
    );
  }
}
