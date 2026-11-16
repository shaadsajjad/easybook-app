import 'package:easybook_app/features/services/domain/entities/time_slot.dart';
import 'package:equatable/equatable.dart';

/// Every slot of one business day for one service.
class Availability extends Equatable {
  const new({required this.serviceId, required this.date, required this.slots});

  final String serviceId;

  /// The business date, "yyyy-MM-dd".
  final String date;
  final List<TimeSlot> slots;

  bool get hasAvailableSlot => slots.any((slot) => slot.available);

  @override
  List<Object> get props => [serviceId, date, slots];
}
