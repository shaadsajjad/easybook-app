import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/widgets/app_logo.dart';
import 'package:flutter/material.dart';

/// The assistant's avatar: the EasyBook logo, so it is clearly the app
/// speaking.
class AssistantAvatar extends StatelessWidget {
  const new({this.size = AppSizes.chatAvatar, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(child: AppLogo(size: size));
  }
}
