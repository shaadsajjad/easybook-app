import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/network/api_envelope.dart';
import 'package:easybook_app/features/ai_assistant/data/models/chat_reply_model.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/chat_message.dart';

/// `POST /ai/chat`. The AI provider and its key live only on the server.
class ChatRemoteDataSource {
  const new(this._dio);

  final Dio _dio;

  Future<ChatReplyModel> sendMessage({
    required String message,
    required List<ChatMessage> history,
  }) async {
    final response = await _dio.post<Object?>(
      ApiEndpoints.aiChat,
      data: {
        'message': message,
        'history': [
          for (final turn in history)
            {'role': turn.role.name, 'content': turn.text},
        ],
      },
      // The server gives the AI 15 s; allow a little more for the network.
      options: Options(receiveTimeout: AppConstants.chatReceiveTimeout),
    );
    return ChatReplyModel.fromJson(ApiEnvelope.dataAsMap(response.data));
  }
}
