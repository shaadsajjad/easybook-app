import 'package:easybook_app/features/services/data/models/pagination_meta_model.dart';
import 'package:easybook_app/features/services/data/models/service_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/service_fixtures.dart';

void main() {
  test('ServiceModel parses the price string and converts to an entity', () {
    final service = ServiceModel.fromJson(tServiceJson).toEntity();
    expect(service, tService);
    expect(service.price, 500.0);
  });

  test('ServiceModel keeps cents', () {
    final json = {...tServiceJson, 'price': '1250.50'};
    expect(ServiceModel.fromJson(json).price, 1250.5);
  });

  test('PaginationMetaModel reads the meta object', () {
    final meta = PaginationMetaModel.fromJson({
      'page': 2,
      'limit': 20,
      'total': 25,
      'totalPages': 2,
    });
    expect(meta.page, 2);
    expect(meta.totalPages, 2);
  });
}
