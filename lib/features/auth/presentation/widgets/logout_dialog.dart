import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Asks "Log out?" and, if confirmed, ends the session. There is no logout
/// endpoint: AuthBloc deletes the token and the router shows the login page.
Future<void> confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(AppIcons.logout),
      title: Text(LocaleKeys.auth_logout_confirm_title.tr()),
      content: Text(LocaleKeys.auth_logout_confirm_message.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(LocaleKeys.common_cancel.tr()),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
            minimumSize: const Size(0, AppSizes.minTapTarget),
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(LocaleKeys.auth_logout.tr()),
        ),
      ],
    ),
  );
  if ((confirmed ?? false) && context.mounted) {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }
}
