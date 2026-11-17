import 'package:easybook_app/features/ai_assistant/domain/entities/suggested_service.dart';
import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant }

/// One message in the conversation.
class ChatMessage extends Equatable {
  const new({
    required this.role,
    required this.text,
    this.suggestions = const [],
  });

  const new user(this.text) : role = ChatRole.user, suggestions = const [];

  final ChatRole role;
  final String text;

  /// Services the assistant mentioned (assistant messages only).
  final List<SuggestedService> suggestions;

  bool get isUser => role == ChatRole.user;

  @override
  List<Object> get props => [role, text, suggestions];
}
