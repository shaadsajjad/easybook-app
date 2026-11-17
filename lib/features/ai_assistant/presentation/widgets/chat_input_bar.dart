import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Text field (max 500 characters) and a send button. Sending is disabled
/// while the field is empty or the assistant is still answering.
class ChatInputBar extends StatefulWidget {
  const new({required this.onSend, required this.isBusy, super.key});

  final ValueChanged<String> onSend;
  final bool isBusy;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  /// Show the "123/500" counter only when close to the limit.
  static const int _counterFrom = 400;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend => _controller.text.trim().isNotEmpty && !widget.isBusy;

  void _send() {
    if (!_canSend) return;
    widget.onSend(_controller.text);
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final length = _controller.text.length;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.outline)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                maxLength: AppConstants.chatMessageMaxLength,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: LocaleKeys.assistant_input_hint.tr(),
                  counterText: length >= _counterFrom ? null : '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              // Pops up and turns lime as soon as there is text to send.
              child: AnimatedScale(
                scale: _canSend ? 1 : 0.85,
                duration: AppDurations.slow,
                curve: AppMotion.pop,
                child: AnimatedRotation(
                  turns: _canSend ? 0 : -0.125,
                  duration: AppDurations.slow,
                  curve: AppMotion.enter,
                  child: IconButton.filled(
                    tooltip: LocaleKeys.assistant_send.tr(),
                    onPressed: _canSend ? _send : null,
                    style: IconButton.styleFrom(
                      backgroundColor: context.palette.solidFill,
                      foregroundColor: context.palette.onSolidFill,
                      minimumSize: const Size.square(AppSizes.buttonHeight - 4),
                    ),
                    icon: const Icon(AppIcons.send),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
