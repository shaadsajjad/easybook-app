import 'package:equatable/equatable.dart';

/// A service named in an assistant reply, shown as a tappable chip.
class SuggestedService extends Equatable {
  const new({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object> get props => [id, name];
}
