import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:easybook_app/features/ai_assistant/domain/usecases/send_chat_message.dart';
import 'package:equatable/equatable.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// The assistant conversation. Each request carries the earlier turns as
/// `history`, because the server does not remember the chat.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  new({required this._sendChatMessage}) : super(const ChatState()) {
    on<ChatMessageSent>(_onMessageSent);
    on<ChatRetried>(_onRetried);
  }

  final SendChatMessage _sendChatMessage;

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();
    // One question at a time.
    if (text.isEmpty || state.isTyping) return;

    final history = state.messages;
    emit(
      state.copyWith(
        messages: [...history, ChatMessage.user(text)],
        isTyping: true,
        failure: () => null,
        failedMessage: () => null,
      ),
    );
    await _ask(text, history, emit);
  }

  Future<void> _onRetried(ChatRetried event, Emitter<ChatState> emit) async {
    final text = state.failedMessage;
    if (text == null || state.isTyping) return;

    // The failed question is already the last message; send it again with
    // the turns before it as history.
    final history = state.messages.sublist(0, state.messages.length - 1);
    emit(
      state.copyWith(
        isTyping: true,
        failure: () => null,
        failedMessage: () => null,
      ),
    );
    await _ask(text, history, emit);
  }

  Future<void> _ask(
    String text,
    List<ChatMessage> history,
    Emitter<ChatState> emit,
  ) async {
    final result = await _sendChatMessage(
      SendChatMessageParams(message: text, history: history),
    );
    emit(
      result.fold(
        (failure) => state.copyWith(
          isTyping: false,
          failure: () => failure,
          failedMessage: () => text,
        ),
        (reply) => state.copyWith(
          messages: [...state.messages, reply],
          isTyping: false,
        ),
      ),
    );
  }
}
