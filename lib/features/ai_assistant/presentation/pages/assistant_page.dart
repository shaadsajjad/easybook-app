import 'dart:async';

import 'package:easybook_app/core/di/injection.dart';
import 'package:easybook_app/core/router/app_routes.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/fade_slide_in.dart';
import 'package:easybook_app/core/widgets/responsive_center.dart';
import 'package:easybook_app/features/ai_assistant/domain/entities/suggested_service.dart';
import 'package:easybook_app/features/ai_assistant/presentation/bloc/chat_bloc.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/assistant_welcome.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/chat_bubble.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/chat_header.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/chat_input_bar.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/retry_bubble.dart';
import 'package:easybook_app/features/ai_assistant/presentation/widgets/typing_indicator.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// The AI assistant tab. The tab stays alive in the bottom navigation, so
/// the conversation is kept while the user looks at other tabs.
class AssistantPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatBloc>(),
      child: const AssistantView(),
    );
  }
}

class AssistantView extends StatelessWidget {
  const new({super.key});

  void _openService(BuildContext context, SuggestedService service) {
    unawaited(context.push(AppRoutes.serviceDetailPath(service.id)));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChatBloc>();
    final firstName = context.select<AuthBloc, String?>(
      (auth) => auth.state.user?.firstName,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: Scaffold(
        body: Column(
          children: [
            const ChatHeader(),
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state.isEmpty) {
                    return AssistantWelcome(
                      firstName: firstName,
                      onPrompt: (prompt) => bloc.add(ChatMessageSent(prompt)),
                    );
                  }
                  return _Conversation(
                    state: state,
                    onServiceTap: (service) => _openService(context, service),
                    onRetry: () => bloc.add(const ChatRetried()),
                  );
                },
              ),
            ),
            BlocSelector<ChatBloc, ChatState, bool>(
              selector: (state) => state.isTyping,
              builder: (context, isTyping) => ChatInputBar(
                isBusy: isTyping,
                onSend: (text) => bloc.add(ChatMessageSent(text)),
              ),
            ),
            // Keep the input above the floating navigation bar (not needed
            // while the keyboard is open: the bar is behind it then).
            ColoredBox(
              color: context.colors.surface,
              child: SizedBox(
                height: MediaQuery.viewInsetsOf(context).bottom > 0
                    ? 0
                    : MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The messages, newest at the bottom. The list is reversed so it starts
/// at the bottom and new messages appear without manual scrolling.
class _Conversation extends StatelessWidget {
  const new({
    required this.state,
    required this.onServiceTap,
    required this.onRetry,
  });

  final ChatState state;
  final ValueChanged<SuggestedService> onServiceTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = state.failure;
    final items = <Widget>[
      for (final message in state.messages)
        // Only the newest message animates in, sliding from its own side.
        // Keyed by the message, so each one gets its entrance exactly once.
        if (identical(message, state.messages.last))
          FadeSlideIn(
            key: ObjectKey(message),
            axis: Axis.horizontal,
            offset: message.isUser
                ? AppMotion.entranceOffset * 2
                : -AppMotion.entranceOffset * 2,
            child: ChatBubble(message: message, onServiceTap: onServiceTap),
          )
        else
          ChatBubble(message: message, onServiceTap: onServiceTap),
      if (state.isTyping) const FadeSlideIn(child: TypingIndicator()),
      if (failure != null)
        FadeSlideIn(
          child: RetryBubble(message: failure.displayMessage, onRetry: onRetry),
        ),
    ].reversed.toList();

    return ListView.separated(
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.lg,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, index) => ResponsiveCenter(child: items[index]),
    );
  }
}
