import 'package:easybook_app/features/services/domain/entities/availability.dart';
import 'package:easybook_app/features/services/domain/entities/time_slot.dart';
import 'package:json_annotation/json_annotation.dart';

part 'availability_model.g.dart';

/// `data` of `GET /services/:id/availability`.
@JsonSerializable(createToJson: false)
class AvailabilityModel {
  const new({required this.serviceId, required this.date, required this.slots});

  factory fromJson(Map<String, dynamic> json) =>
      _$AvailabilityModelFromJson(json);

  final String serviceId;
  final String date;
  final List<TimeSlotModel> slots;

  Availability toEntity() => Availability(
    serviceId: serviceId,
    date: date,
    slots: slots.map((slot) => slot.toEntity()).toList(),
  );
}

/// `{ startTime, endTime, available }`, times in UTC ISO 8601.
@JsonSerializable(createToJson: false)
class TimeSlotModel {
  const new({
    required this.startTime,
    required this.endTime,
    required this.available,
  });

  factory fromJson(Map<String, dynamic> json) => _$TimeSlotModelFromJson(json);

  // Kept as strings: the start is sent back to the API exactly as received.
  final String startTime;
  final String endTime;
  final bool available;

  TimeSlot toEntity() => TimeSlot(
    startTimeValue: startTime,
    start: DateTime.parse(startTime),
    end: DateTime.parse(endTime),
    available: available,
  );
}
