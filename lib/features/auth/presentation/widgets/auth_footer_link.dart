import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// "New to EasyBook? Create an account" style link under a form.
class AuthFooterLink extends StatelessWidget {
  const new({
    required this.question,
    required this.action,
    required this.onPressed,
    super.key,
  });

  final String question;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          question,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
        TextButton(onPressed: onPressed, child: Text(action)),
      ],
    );
  }
}
