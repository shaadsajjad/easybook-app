/// The life cycle of a booking. New bookings start as [pending].
enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  /// Only pending bookings can be cancelled (the API returns 409 otherwise).
  bool get canCancel => this == AppointmentStatus.pending;
}
