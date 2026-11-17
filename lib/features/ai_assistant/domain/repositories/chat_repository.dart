import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ChatRepository {
  /// Sends [message] with the earlier turns ([history], oldest first) and
  /// returns the assistant's reply as a [ChatMessage].
  ///
  /// 429 (too many messages) and 502/503 (assistant busy or down) come back
  /// as RateLimitFailure and ServiceUnavailableFailure with a friendly text.
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String message,
    required List<ChatMessage> history,
  });
}
