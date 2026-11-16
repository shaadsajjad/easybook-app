import 'package:equatable/equatable.dart';

/// One bookable time on the availability screen.
class TimeSlot extends Equatable {
  const new({
    required this.startTimeValue,
    required this.start,
    required this.end,
    required this.available,
  });

  /// The `startTime` string exactly as the API sent it. Booking sends this
  /// back unchanged, so the server always receives a time on its own grid.
  final String startTimeValue;

  /// Start and end as UTC DateTimes (convert to local only for display).
  final DateTime start;
  final DateTime end;

  /// False when booked, already started, or too late to finish by closing.
  final bool available;

  @override
  List<Object> get props => [startTimeValue, start, end, available];
}
