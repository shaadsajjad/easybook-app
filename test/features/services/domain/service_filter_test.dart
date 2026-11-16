import 'package:easybook_app/features/services/domain/entities/service_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an empty filter is not active', () {
    expect(const ServiceFilter().isActive, isFalse);
    expect(const ServiceFilter(search: '   ').isActive, isFalse);
  });

  test('search, category or price make it active', () {
    expect(const ServiceFilter(search: 'cut').isActive, isTrue);
    expect(const ServiceFilter(category: 'Health').isActive, isTrue);
    expect(const ServiceFilter(maxPrice: 1000).isActive, isTrue);
    expect(const ServiceFilter(minPrice: 0).hasPriceRange, isTrue);
  });

  test('each "with" method changes one part and keeps the rest', () {
    const filter = ServiceFilter(
      search: 'cut',
      category: 'Hair & Beauty',
      minPrice: 100,
      maxPrice: 900,
    );
    expect(
      filter.withSearch('spa'),
      const ServiceFilter(
        search: 'spa',
        category: 'Hair & Beauty',
        minPrice: 100,
        maxPrice: 900,
      ),
    );
    expect(filter.withCategory(null).category, isNull);
    expect(filter.withCategory(null).search, 'cut');
    expect(
      filter.withPriceRange(),
      const ServiceFilter(search: 'cut', category: 'Hair & Beauty'),
    );
  });
}
