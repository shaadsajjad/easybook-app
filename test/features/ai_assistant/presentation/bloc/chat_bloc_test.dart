import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:easybook_app/features/ai_assistant/domain/usecases/send_chat_message.dart';
import 'package:easybook_app/features/ai_assistant/presentation/bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/chat_fixtures.dart';

class _MockSendChatMessage extends Mock implements SendChatMessage;

const _busy = ServiceUnavailableFailure(
  'The assistant is busy right now. Please try again in a minute.',
);

void main() {
  late _MockSendChatMessage sendChatMessage;

  setUpAll(
    () => registerFallbackValue(
      const SendChatMessageParams(message: '', history: []),
    ),
  );

  setUp(() {
    sendChatMessage = _MockSendChatMessage();
    when(() => sendChatMessage(any()))
        .thenAnswer((_) async => const Right(tAssistantReply));
  });

  ChatBloc build() => ChatBloc(sendChatMessage: sendChatMessage);

  test('starts empty', () {
    expect(build().state.isEmpty, isTrue);
  });

  blocTest<ChatBloc, ChatState>(
    'shows the question, the typing dots, then the reply',
    build: build,
    act: (bloc) => bloc.add(const ChatMessageSent(' I have a stiff back. ')),
    expect: () => [
      const ChatState(messages: [tQuestion], isTyping: true),
      const ChatState(messages: [tQuestion, tAssistantReply]),
    ],
    verify: (_) => verify(
      () => sendChatMessage(
        const SendChatMessageParams(
          message: 'I have a stiff back.',
          history: [],
        ),
      ),
    ).called(1),
  );

  blocTest<ChatBloc, ChatState>(
    'sends the earlier turns as history',
    seed: () => const ChatState(messages: [tQuestion, tAssistantReply]),
    build: build,
    act: (bloc) => bloc.add(const ChatMessageSent('Anything cheaper?')),
    verify: (_) => verify(
      () => sendChatMessage(
        const SendChatMessageParams(
          message: 'Anything cheaper?',
          history: [tQuestion, tAssistantReply],
        ),
      ),
    ).called(1),
  );

  blocTest<ChatBloc, ChatState>(
    'ignores empty messages',
    build: build,
    act: (bloc) => bloc.add(const ChatMessageSent('   ')),
    expect: () => <ChatState>[],
  );

  blocTest<ChatBloc, ChatState>(
    'ignores a new message while the assistant is answering',
    seed: () => const ChatState(messages: [tQuestion], isTyping: true),
    build: build,
    act: (bloc) => bloc.add(const ChatMessageSent('hello?')),
    expect: () => <ChatState>[],
  );

  blocTest<ChatBloc, ChatState>(
    'keeps the question and shows the failure for retry',
    setUp: () =>
        when(() => sendChatMessage(any()))
            .thenAnswer((_) async => const Left(_busy)),
    build: build,
    act: (bloc) => bloc.add(const ChatMessageSent('I have a stiff back.')),
    expect: () => [
      const ChatState(messages: [tQuestion], isTyping: true),
      const ChatState(
        messages: [tQuestion],
        failure: _busy,
        failedMessage: 'I have a stiff back.',
      ),
    ],
  );

  blocTest<ChatBloc, ChatState>(
    'retry sends the failed question again without repeating it',
    seed: () => const ChatState(
      messages: [tQuestion],
      failure: _busy,
      failedMessage: 'I have a stiff back.',
    ),
    build: build,
    act: (bloc) => bloc.add(const ChatRetried()),
    expect: () => [
      const ChatState(messages: [tQuestion], isTyping: true),
      const ChatState(messages: [tQuestion, tAssistantReply]),
    ],
    verify: (_) => verify(
      () => sendChatMessage(
        const SendChatMessageParams(
          message: 'I have a stiff back.',
          history: [],
        ),
      ),
    ).called(1),
  );

  blocTest<ChatBloc, ChatState>(
    'retry does nothing when nothing failed',
    build: build,
    act: (bloc) => bloc.add(const ChatRetried()),
    expect: () => <ChatState>[],
  );

  blocTest<ChatBloc, ChatState>(
    'a new message clears the old failure',
    seed: () => const ChatState(
      messages: [tQuestion],
      failure: RateLimitFailure('Too many messages'),
      failedMessage: 'I have a stiff back.',
    ),
    build: build,
    act: (bloc) => bloc.add(const ChatMessageSent('hi')),
    verify: (bloc) {
      expect(bloc.state.failure, isNull);
      expect(bloc.state.messages.last, tAssistantReply);
      expect(bloc.state.messages[1], const ChatMessage.user('hi'));
    },
  );
}
