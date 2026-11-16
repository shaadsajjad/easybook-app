/// The two lists on My Bookings. The names match the API's `?type=`.
///
/// - [upcoming]: starts now or later and is PENDING or CONFIRMED.
/// - [past]: everything else (earlier, cancelled or completed).
enum BookingsTab { upcoming, past }
