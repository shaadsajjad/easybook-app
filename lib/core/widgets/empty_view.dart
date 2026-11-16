import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/feedback_message.dart';
import 'package:flutter/material.dart';

/// Full-area empty state: an icon, a title, a hint and an optional action.
class EmptyView extends StatelessWidget {
  const new({
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return FeedbackMessage(
      icon: icon,
      iconColor: context.colors.primary,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
