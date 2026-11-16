import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easybook_app/features/auth/presentation/widgets/logout_dialog.dart';
import 'package:easybook_app/features/profile/presentation/widgets/language_sheet.dart';
import 'package:easybook_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:easybook_app/features/profile/presentation/widgets/profile_menu_tile.dart';
import 'package:easybook_app/features/profile/presentation/widgets/profile_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// The user's profile, settings and logout. The user comes from AuthBloc,
/// so edits made on the edit page show here right away.
class ProfilePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, User?>((bloc) => bloc.state.user);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            children: [
              ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      LocaleKeys.profile_title.tr(),
                      style: context.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (user != null) ProfileHeader(user: user),
                    const SizedBox(height: AppSpacing.xl),
                    ProfileSection(
                      title: LocaleKeys.profile_account_section.tr(),
                      tiles: [
                        ProfileMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: LocaleKeys.profile_edit_profile.tr(),
                          subtitle: LocaleKeys.profile_edit_profile_subtitle
                              .tr(),
                          onTap: () => context.push(AppRoutes.editProfilePath),
                        ),
                        ProfileMenuTile(
                          icon: Icons.lock_outline_rounded,
                          title: LocaleKeys.profile_change_password.tr(),
                          subtitle: LocaleKeys.profile_change_password_subtitle
                              .tr(),
                          onTap: () =>
                              context.push(AppRoutes.changePasswordPath),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ProfileSection(
                      title: LocaleKeys.profile_preferences_section.tr(),
                      tiles: [
                        ProfileMenuTile(
                          icon: Icons.translate_rounded,
                          title: LocaleKeys.profile_language.tr(),
                          subtitle: LanguageSheet.labelFor(
                            Localizations.localeOf(context),
                          ),
                          onTap: () => LanguageSheet.show(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ProfileSection(
                      tiles: [
                        ProfileMenuTile(
                          icon: Icons.logout_rounded,
                          title: LocaleKeys.auth_logout.tr(),
                          subtitle: LocaleKeys.profile_logout_subtitle.tr(),
                          destructive: true,
                          onTap: () => confirmLogout(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
