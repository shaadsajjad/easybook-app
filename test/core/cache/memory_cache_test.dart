import 'package:easybook_app/core/cache/memory_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime now;
  late MemoryCache<String, int> cache;

  setUp(() {
    now = DateTime(2026, 11, 18, 10);
    cache = MemoryCache(ttl: const Duration(minutes: 5), now: () => now);
  });

  test('returns null for a key that was never saved', () {
    expect(cache.get('a'), isNull);
  });

  test('returns a saved value while it is fresh', () {
    cache.set('a', 1);
    now = now.add(const Duration(minutes: 4, seconds: 59));
    expect(cache.get('a'), 1);
  });

  test('forgets a value once the time limit has passed', () {
    cache.set('a', 1);
    now = now.add(const Duration(minutes: 5));
    expect(cache.get('a'), isNull);
  });

  test('saving again restarts the time limit', () {
    cache.set('a', 1);
    now = now.add(const Duration(minutes: 4));
    cache.set('a', 2);
    now = now.add(const Duration(minutes: 4));
    expect(cache.get('a'), 2);
  });

  test('remove and clear forget entries', () {
    cache
      ..set('a', 1)
      ..set('b', 2)
      ..remove('a');
    expect(cache.get('a'), isNull);
    expect(cache.get('b'), 2);

    cache.clear();
    expect(cache.get('b'), isNull);
  });
}
