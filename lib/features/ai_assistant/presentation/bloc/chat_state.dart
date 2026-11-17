part of 'chat_bloc.dart';

final class ChatState extends Equatable {
  const new({
    this.messages = const [],
    this.isTyping = false,
    this.failure,
    this.failedMessage,
  });

  /// The conversation, oldest first. It lives only in this state: the
  /// server keeps no history.
  final List<ChatMessage> messages;

  /// Waiting for the assistant (shows the typing dots).
  final bool isTyping;

  /// Why the last message got no answer (shown as an error bubble).
  final Failure? failure;

  /// The message to send again when the user taps "Try again".
  final String? failedMessage;

  bool get isEmpty => messages.isEmpty && !isTyping && failure == null;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    Failure? Function()? failure,
    String? Function()? failedMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      failure: failure != null ? failure() : this.failure,
      failedMessage: failedMessage != null
          ? failedMessage()
          : this.failedMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isTyping, failure, failedMessage];
}
