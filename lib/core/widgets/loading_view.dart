import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// A centered spinner with an optional message underneath.
class LoadingView extends StatelessWidget {
  const new({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: AppSizes.progressStroke,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
