import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/widgets/empty_view.dart';
import 'package:flutter/material.dart';

/// Temporary screen for routes whose feature is built in a later step.
/// Each step replaces its placeholders with the real pages.
class PlaceholderPage extends StatelessWidget {
  const new({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyView(
        icon: Icons.construction_rounded,
        title: title,
        message: LocaleKeys.common_coming_soon.tr(),
      ),
    );
  }
}
