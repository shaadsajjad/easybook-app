import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:easybook_app/features/ai_assistant/domain/repositories/chat_repository.dart';
import 'package:easybook_app/features/ai_assistant/domain/usecases/send_chat_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/chat_fixtures.dart';

class _MockRepository extends Mock implements ChatRepository;

void main() {
  late _MockRepository repository;
  late SendChatMessage sendChatMessage;

  setUp(() {
    repository = _MockRepository();
    sendChatMessage = SendChatMessage(repository);
    when(
      () => repository.sendMessage(
        message: any(named: 'message'),
        history: any(named: 'history'),
      ),
    ).thenAnswer((_) async => const Right(tAssistantReply));
  });

  test('trims the message and sends a short history unchanged', () async {
    await sendChatMessage(
      const SendChatMessageParams(message: '  hi  ', history: [tQuestion]),
    );
    verify(() => repository.sendMessage(message: 'hi', history: [tQuestion]))
        .called(1);
  });

  test('sends only the last 10 turns, oldest first', () async {
    final history = [
      for (var i = 0; i < 14; i++) ChatMessage.user('message $i'),
    ];

    await sendChatMessage(
      SendChatMessageParams(message: 'next', history: history),
    );

    final sent =
        verify(
              () => repository.sendMessage(
                message: 'next',
                history: captureAny(named: 'history'),
              ),
            ).captured.single
            as List<ChatMessage>;
    expect(sent, hasLength(AppConstants.chatHistoryLimit));
    expect(sent.first.text, 'message 4');
    expect(sent.last.text, 'message 13');
  });
}
