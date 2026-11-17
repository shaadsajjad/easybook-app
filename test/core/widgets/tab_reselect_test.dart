import 'dart:async';

import 'package:easybook_app/core/widgets/tab_reselect.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('calls onReselect only for its own tab', (tester) async {
    final controller = StreamController<int>.broadcast();
    addTearDown(controller.close);
    var calls = 0;

    await tester.pumpWidget(
      TabReselectScope(
        reselections: controller.stream,
        child: TabReselectListener(
          tab: 1,
          onReselect: () => calls++,
          child: const SizedBox(),
        ),
      ),
    );

    controller
      ..add(0)
      ..add(1);
    await tester.pump();

    expect(calls, 1);
  });

  testWidgets('does nothing outside the app shell', (tester) async {
    await tester.pumpWidget(
      TabReselectListener(tab: 0, onReselect: () {}, child: const SizedBox()),
    );
    expect(tester.takeException(), isNull);
  });
}
