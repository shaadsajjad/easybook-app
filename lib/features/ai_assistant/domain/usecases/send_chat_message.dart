import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:easybook_app/features/ai_assistant/domain/repositories/chat_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

class SendChatMessageParams extends Equatable {
  const new({required this.message, required this.history});

  final String message;

  /// The whole conversation so far, oldest first.
  final List<ChatMessage> history;

  @override
  List<Object> get props => [message, history];
}

/// The server keeps no chat history, so the app sends earlier turns along.
/// Only the last 10 are sent: that is all the server uses.
class SendChatMessage {
  const new(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatMessage>> call(SendChatMessageParams params) {
    final history = params.history;
    final recent = history.length > AppConstants.chatHistoryLimit
        ? history.sublist(history.length - AppConstants.chatHistoryLimit)
        : history;
    return _repository.sendMessage(
      message: params.message.trim(),
      history: recent,
    );
  }
}
