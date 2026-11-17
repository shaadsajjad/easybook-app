import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// The assistant's round gradient avatar with a sparkle.
class AssistantAvatar extends StatelessWidget {
  const new({this.size = AppSizes.chatAvatar, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: context.palette.brandGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        size: size * 0.55,
        color: context.colors.onPrimary,
      ),
    );
  }
}
