/// A short, human-friendly booking number such as "B-26047", for showing
/// and reading out (on the phone, at the counter).
///
/// The API only has the long UUID `id`, so the number is derived from it:
/// "B-", the last two digits of the year the booking was made, then three
/// digits computed from the id. The same booking always gets the same
/// number, on every device. It is a display label only: the app still uses
/// the real `id` for every request.
abstract final class BookingReference {
  static const String _prefix = 'B-';

  static String format({required String id, required DateTime createdAt}) {
    final year = (createdAt.toLocal().year % 100).toString().padLeft(2, '0');
    // 001..999, so it never reads as "000".
    final number = (_hash(id) % 999 + 1).toString().padLeft(3, '0');
    return '$_prefix$year$number';
  }

  /// FNV-1a: a small, stable string hash (unlike `String.hashCode`, it is
  /// the same on every run and platform).
  static int _hash(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    return hash;
  }
}
