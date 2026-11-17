import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/network/request_guard.dart';
import 'package:easybook_app/features/ai_assistant/data/datasources/chat_remote_data_source.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:easybook_app/features/ai_assistant/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

class ChatRepositoryImpl implements ChatRepository {
  const new(this._remote);

  final ChatRemoteDataSource _remote;

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String message,
    required List<ChatMessage> history,
  }) {
    return guardRequest(() async {
      final reply = await _remote.sendMessage(
        message: message,
        history: history,
      );
      return reply.toEntity();
    });
  }
}
