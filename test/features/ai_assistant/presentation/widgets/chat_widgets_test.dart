import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/suggested_service.dart';
import 'package:easybook_app/features/ai_assistant/presentation/bloc/chat_bloc.dart';
import 'package:easybook_app/features/ai_assistant/presentation/pages/assistant_page.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/chat_bubble.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/chat_input_bar.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/typing_indicator.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_fixtures.dart';
import '../../../../helpers/chat_fixtures.dart';
import '../../../../helpers/helpers.dart';

class _MockChatBloc extends MockBloc<ChatEvent, ChatState> implements ChatBloc;

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc;

void main() {
  late _MockChatBloc chatBloc;
  late _MockAuthBloc authBloc;

  setUpAll(() => registerFallbackValue(const ChatRetried()));

  setUp(() {
    chatBloc = _MockChatBloc();
    authBloc = _MockAuthBloc();
    when(() => authBloc.state).thenReturn(AuthState.authenticated(tUser));
  });

  Future<void> pumpView(WidgetTester tester, ChatState state) {
    when(() => chatBloc.state).thenReturn(state);
    return tester.pumpApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<ChatBloc>.value(value: chatBloc),
          BlocProvider<AuthBloc>.value(value: authBloc),
        ],
        child: const AssistantView(),
      ),
    );
  }

  testWidgets('the welcome screen sends a tapped example question', (
    tester,
  ) async {
    await pumpView(tester, const ChatState());

    expect(find.text(LocaleKeys.assistant_welcome_title), findsOneWidget);
    // Let the cards finish their entrance animation before tapping.
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text(LocaleKeys.assistant_prompt_haircut));

    verify(
      () => chatBloc.add(
        const ChatMessageSent(LocaleKeys.assistant_prompt_haircut),
      ),
    ).called(1);
  });

  testWidgets('shows both bubbles, and the typing dots while waiting', (
    tester,
  ) async {
    await pumpView(
      tester,
      const ChatState(messages: [tQuestion, tAssistantReply], isTyping: true),
    );

    expect(find.text('I have a stiff back.'), findsOneWidget);
    expect(find.text(tAssistantReply.text), findsOneWidget);
    expect(find.text('Full Body Massage'), findsOneWidget);
    expect(find.byType(TypingIndicator), findsOneWidget);
  });

  testWidgets('an error shows the message and Try again', (tester) async {
    await pumpView(
      tester,
      const ChatState(
        messages: [tQuestion],
        failure: ServiceUnavailableFailure('The assistant is busy.'),
        failedMessage: 'I have a stiff back.',
      ),
    );

    expect(find.text('The assistant is busy.'), findsOneWidget);
    await tester.tap(find.text(LocaleKeys.assistant_retry));
    verify(() => chatBloc.add(const ChatRetried())).called(1);
  });

  testWidgets('a suggested service chip reports which service was tapped', (
    tester,
  ) async {
    SuggestedService? tapped;
    await tester.pumpApp(
      ChatBubble(
        message: tAssistantReply,
        onServiceTap: (service) => tapped = service,
      ),
    );

    await tester.tap(find.text('Full Body Massage'));
    expect(tapped, tAssistantReply.suggestions.single);
  });

  group('ChatInputBar', () {
    testWidgets('sends the text and clears the field', (tester) async {
      String? sent;
      await tester.pumpApp(
        ChatInputBar(isBusy: false, onSend: (text) => sent = text),
      );

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();

      expect(sent, 'Hello');
      expect(find.text('Hello'), findsNothing);
    });

    testWidgets('cannot send empty text or while the assistant answers', (
      tester,
    ) async {
      var sends = 0;
      await tester.pumpApp(ChatInputBar(isBusy: true, onSend: (_) => sends++));

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      expect(sends, 0);
    });

    testWidgets('limits messages to 500 characters', (tester) async {
      await tester.pumpApp(ChatInputBar(isBusy: false, onSend: (_) {}));

      await tester.enterText(find.byType(TextField), 'a' * 600);
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text.length, 500);
    });
  });
}
