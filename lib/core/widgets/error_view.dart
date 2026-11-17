import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/feedback_message.dart';
import 'package:flutter/material.dart';

/// Full-area error state: what went wrong and a retry button.
class ErrorView extends StatelessWidget {
  const new({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return FeedbackMessage(
      icon: AppIcons.error,
      iconColor: context.colors.error,
      title: LocaleKeys.errors_title.tr(),
      message: message,
      actionLabel: LocaleKeys.common_retry.tr(),
      actionIcon: AppIcons.retry,
      onAction: onRetry,
    );
  }
}
