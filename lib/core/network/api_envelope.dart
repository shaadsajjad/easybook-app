import 'package:easybook_app/core/error/exceptions.dart';

/// Reads the API's response envelope:
/// `{ success, data?, message?, meta?, errors? }`.
///
/// All envelope parsing lives here so data sources and widgets never touch
/// raw JSON keys like `success` or `errors`.
abstract final class ApiEnvelope {
  /// The whole body as a map, or a [ParsingException].
  static Map<String, dynamic> body(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    throw const ParsingException('Response body is not a JSON object');
  }

  /// `data` as a JSON object (for example a user or a service).
  static Map<String, dynamic> dataAsMap(Object? raw) {
    final data = body(raw)['data'];
    if (data is Map<String, dynamic>) return data;
    throw const ParsingException('Expected "data" to be an object');
  }

  /// `data` as a list of JSON objects (for example a page of services).
  static List<Map<String, dynamic>> dataAsList(Object? raw) {
    final data = body(raw)['data'];
    if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    throw const ParsingException('Expected "data" to be a list');
  }

  /// `data` as a list of strings (for example the category names).
  static List<String> dataAsStringList(Object? raw) {
    final data = body(raw)['data'];
    if (data is List) return data.whereType<String>().toList();
    throw const ParsingException('Expected "data" to be a list');
  }

  /// `meta` (pagination), or a [ParsingException] if it is missing.
  static Map<String, dynamic> meta(Object? raw) {
    final meta = body(raw)['meta'];
    if (meta is Map<String, dynamic>) return meta;
    throw const ParsingException('Expected "meta" to be an object');
  }

  /// The human-readable `message`, if the body has one.
  static String? message(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final message = raw['message'];
    return message is String && message.isNotEmpty ? message : null;
  }

  /// Groups `errors: [{ field, message }]` by field.
  /// A field can have several messages (for example two password rules).
  static Map<String, List<String>> fieldErrors(Object? raw) {
    if (raw is! Map<String, dynamic>) return const {};
    final errors = raw['errors'];
    if (errors is! List) return const {};

    final result = <String, List<String>>{};
    for (final item in errors.whereType<Map<String, dynamic>>()) {
      final field = item['field'];
      final message = item['message'];
      if (field is String && message is String) {
        result.putIfAbsent(field, () => []).add(message);
      }
    }
    return result;
  }
}
