import 'package:easybook_app/core/error/exceptions.dart';
import 'package:easybook_app/core/network/api_envelope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiEnvelope', () {
    test('reads data as a map', () {
      final body = {
        'success': true,
        'data': {'id': '1'},
      };
      expect(ApiEnvelope.dataAsMap(body), {'id': '1'});
    });

    test('reads data as a list of maps', () {
      final body = {
        'success': true,
        'data': [
          {'id': '1'},
          {'id': '2'},
        ],
      };
      expect(ApiEnvelope.dataAsList(body), hasLength(2));
    });

    test('reads data as a list of strings', () {
      final body = {
        'success': true,
        'data': ['Health', 'Wellness'],
      };
      expect(ApiEnvelope.dataAsStringList(body), ['Health', 'Wellness']);
    });

    test('reads pagination meta', () {
      final body = {
        'success': true,
        'data': <Object>[],
        'meta': {'page': 1, 'limit': 20, 'total': 0, 'totalPages': 0},
      };
      expect(ApiEnvelope.meta(body)['totalPages'], 0);
    });

    test('throws ParsingException when the shape is wrong', () {
      expect(() => ApiEnvelope.body('oops'), throwsA(isA<ParsingException>()));
      expect(
        () => ApiEnvelope.dataAsMap({'data': <Object>[]}),
        throwsA(isA<ParsingException>()),
      );
      expect(
        () => ApiEnvelope.dataAsList({'data': <String, Object>{}}),
        throwsA(isA<ParsingException>()),
      );
      expect(
        () => ApiEnvelope.meta({'data': <Object>[]}),
        throwsA(isA<ParsingException>()),
      );
    });

    test('reads the message, ignoring empty or missing ones', () {
      expect(ApiEnvelope.message({'message': 'Logged in'}), 'Logged in');
      expect(ApiEnvelope.message({'message': ''}), isNull);
      expect(ApiEnvelope.message(<String, Object>{}), isNull);
      expect(ApiEnvelope.message('not a map'), isNull);
    });

    test('groups field errors by field, keeping every message', () {
      final body = {
        'success': false,
        'message': 'Validation failed',
        'errors': [
          {'field': 'password', 'message': 'Too short'},
          {'field': 'password', 'message': 'Needs a number'},
          {'field': 'email', 'message': 'Invalid'},
          {'field': 1, 'message': 'ignored'},
        ],
      };
      expect(ApiEnvelope.fieldErrors(body), {
        'password': ['Too short', 'Needs a number'],
        'email': ['Invalid'],
      });
    });

    test('returns no field errors when there are none', () {
      expect(ApiEnvelope.fieldErrors({'success': false}), isEmpty);
      expect(ApiEnvelope.fieldErrors(null), isEmpty);
    });
  });
}
