part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// The user sent a message (typed or tapped a suggested prompt).
final class ChatMessageSent extends ChatEvent {
  const new(this.text);

  final String text;

  @override
  List<Object> get props => [text];
}

/// "Try again" on the error bubble.
final class ChatRetried extends ChatEvent {
  const new();
}
