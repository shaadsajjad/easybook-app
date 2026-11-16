import 'package:equatable/equatable.dart';

class SplashState extends Equatable {
  const new({this.showWakeUpHint = false});

  final bool showWakeUpHint;

  @override
  List<Object> get props => [showWakeUpHint];
}
