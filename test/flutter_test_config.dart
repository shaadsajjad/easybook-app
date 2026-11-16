import 'dart:async';

import 'package:easy_localization/easy_localization.dart';

/// Runs before every test file. Translations are not loaded in tests
/// (tr() returns the key), so the "key not found" warnings are switched off.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  EasyLocalization.logger.enableBuildModes = [];
  await testMain();
}
