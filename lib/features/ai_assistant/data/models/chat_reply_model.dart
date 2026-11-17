import 'package:easybook_app/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/suggested_service.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_reply_model.g.dart';

/// `data` of `POST /ai/chat`: `{ reply, suggestedServices: [{ id, name }] }`.
@JsonSerializable(createToJson: false)
class ChatReplyModel {
  const new({required this.reply, this.suggestedServices = const []});

  factory fromJson(Map<String, dynamic> json) => _$ChatReplyModelFromJson(json);

  final String reply;
  final List<SuggestedServiceModel> suggestedServices;

  ChatMessage toEntity() => ChatMessage(
    role: ChatRole.assistant,
    text: reply,
    suggestions: suggestedServices.map((s) => s.toEntity()).toList(),
  );
}

@JsonSerializable(createToJson: false)
class SuggestedServiceModel {
  const new({required this.id, required this.name});

  factory fromJson(Map<String, dynamic> json) =>
      _$SuggestedServiceModelFromJson(json);

  final String id;
  final String name;

  SuggestedService toEntity() => SuggestedService(id: id, name: name);
}
