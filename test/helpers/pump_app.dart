import 'package:easybook_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside a themed MaterialApp + Scaffold.
  ///
  /// Translations are not loaded in widget tests, so `tr()` returns the
  /// key itself (for example `common.retry`). Tests can find text by key.
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: widget),
      ),
    );
  }
}
