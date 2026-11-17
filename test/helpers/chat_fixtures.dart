import 'package:easybook_app/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/suggested_service.dart';

/// A reply exactly as `POST /ai/chat` returns it (docs/API.md).
const Map<String, dynamic> tChatReplyJson = {
  'reply':
      'For a stiff back from desk work, I recommend the Full Body Massage. '
      'The price is 3,000 BDT.',
  'suggestedServices': [
    {'id': '5e000000-0000-4000-8000-000000000004', 'name': 'Full Body Massage'},
  ],
};

const ChatMessage tAssistantReply = ChatMessage(
  role: ChatRole.assistant,
  text:
      'For a stiff back from desk work, I recommend the Full Body Massage. '
      'The price is 3,000 BDT.',
  suggestions: [
    SuggestedService(
      id: '5e000000-0000-4000-8000-000000000004',
      name: 'Full Body Massage',
    ),
  ],
);

const ChatMessage tQuestion = ChatMessage.user('I have a stiff back.');
