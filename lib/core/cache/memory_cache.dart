/// A small in-memory cache where every entry expires after [ttl].
///
/// Used by repositories (data layer) to avoid calling the API again for
/// data that rarely changes. It lives as long as the repository (the whole
/// app session) and is lost when the app closes. Blocs and widgets never
/// see it.
class MemoryCache<K, V> {
  /// [now] can be replaced in tests to move time forward.
  new({required this.ttl, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final Duration ttl;
  final DateTime Function() _now;
  final Map<K, _Entry<V>> _entries = {};

  /// The value saved for [key], or null if there is none or it expired.
  V? get(K key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (_now().difference(entry.savedAt) >= ttl) {
      _entries.remove(key);
      return null;
    }
    return entry.value;
  }

  void set(K key, V value) => _entries[key] = _Entry(value, _now());

  /// Forgets one entry.
  void remove(K key) => _entries.remove(key);

  /// Forgets every entry (for example before a forced refresh).
  void clear() => _entries.clear();
}

class _Entry<V> {
  const new(this.value, this.savedAt);

  final V value;
  final DateTime savedAt;
}
