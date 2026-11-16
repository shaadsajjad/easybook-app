import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/features/services/presentation/widgets/price_filter_sheet.dart';
import 'package:easybook_app/features/services/presentation/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/helpers.dart';
import '../../../../helpers/service_fixtures.dart';

void main() {
  testWidgets('ServiceCard shows the name, category and price', (tester) async {
    var taps = 0;
    await tester.pumpApp(ServiceCard(service: tService, onTap: () => taps++));

    expect(find.text('Classic Haircut'), findsOneWidget);
    expect(find.text('Hair & Beauty'), findsOneWidget);
    expect(find.text('৳500'), findsOneWidget);
    await tester.tap(find.byType(ServiceCard));
    expect(taps, 1);
  });

  group('PriceFilterSheet', () {
    Future<PriceRange?> openSheet(
      WidgetTester tester, {
      PriceRange initial = (min: null, max: null),
    }) async {
      PriceRange? result;
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await PriceFilterSheet.show(context, initial),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('returns the typed range', (tester) async {
      PriceRange? result;
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await PriceFilterSheet.show(
              context,
              (min: null, max: null),
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '500');
      await tester.enterText(fields.at(1), '2000');
      await tester.tap(find.text(LocaleKeys.services_apply_filter));
      await tester.pumpAndSettle();

      expect(result, (min: 500.0, max: 2000.0));
    });

    testWidgets('blocks a max price lower than the min price', (tester) async {
      await openSheet(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '3000');
      await tester.enterText(fields.at(1), '1000');
      await tester.tap(find.text(LocaleKeys.services_apply_filter));
      await tester.pumpAndSettle();

      expect(find.text(LocaleKeys.services_price_order), findsOneWidget);
      expect(find.byType(PriceFilterSheet), findsOneWidget);
    });

    testWidgets('starts with the current range filled in', (tester) async {
      await openSheet(tester, initial: (min: 1000, max: 3000));

      expect(find.text('1000'), findsOneWidget);
      expect(find.text('3000'), findsOneWidget);
    });
  });
}
