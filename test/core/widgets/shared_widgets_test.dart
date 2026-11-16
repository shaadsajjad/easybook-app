import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/status_colors.dart';
import 'package:easybook_app/core/widgets/app_button.dart';
import 'package:easybook_app/core/widgets/app_logo.dart';
import 'package:easybook_app/core/widgets/app_text_field.dart';
import 'package:easybook_app/core/widgets/empty_view.dart';
import 'package:easybook_app/core/widgets/error_view.dart';
import 'package:easybook_app/core/widgets/loading_view.dart';
import 'package:easybook_app/core/widgets/section_header.dart';
import 'package:easybook_app/core/widgets/skeleton.dart';
import 'package:easybook_app/core/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      var taps = 0;
      await tester.pumpApp(AppButton(label: 'Book', onPressed: () => taps++));

      await tester.tap(find.text('Book'));
      expect(taps, 1);
    });

    testWidgets('shows a spinner and ignores taps while loading', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        AppButton(label: 'Book', isLoading: true, onPressed: () => taps++),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Book'), findsNothing);
      await tester.tap(find.byType(AppButton));
      expect(taps, 0);
    });

    testWidgets('renders the secondary and text variants', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            AppButton(
              label: 'Secondary',
              icon: Icons.add,
              variant: AppButtonVariant.secondary,
              onPressed: () {},
            ),
            AppButton(
              label: 'Text',
              variant: AppButtonVariant.text,
              onPressed: () {},
            ),
          ],
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('AppTextField', () {
    testWidgets('shows the label and a server error', (tester) async {
      await tester.pumpApp(
        const AppTextField(label: 'Email', errorText: 'Already registered'),
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Already registered'), findsOneWidget);
    });

    testWidgets('password fields can be shown and hidden', (tester) async {
      await tester.pumpApp(
        const AppTextField(label: 'Password', isPassword: true),
      );

      bool obscured() =>
          tester.widget<EditableText>(find.byType(EditableText)).obscureText;

      expect(obscured(), isTrue);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(obscured(), isFalse);
    });
  });

  group('ErrorView', () {
    testWidgets('shows the message and calls onRetry', (tester) async {
      var retries = 0;
      await tester.pumpApp(
        ErrorView(message: 'Server is down', onRetry: () => retries++),
      );

      expect(find.text('Server is down'), findsOneWidget);
      await tester.tap(find.text(LocaleKeys.common_retry));
      expect(retries, 1);
    });
  });

  group('EmptyView', () {
    testWidgets('shows the title, message and action', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        EmptyView(
          title: 'No bookings yet',
          message: 'Book your first service',
          actionLabel: 'Browse',
          onAction: () => taps++,
        ),
      );

      expect(find.text('No bookings yet'), findsOneWidget);
      expect(find.text('Book your first service'), findsOneWidget);
      await tester.tap(find.text('Browse'));
      expect(taps, 1);
    });
  });

  group('StatusChip', () {
    testWidgets('always shows its label', (tester) async {
      await tester.pumpApp(
        const StatusChip(label: 'Pending', tone: StatusTone.warning),
      );
      expect(find.text('Pending'), findsOneWidget);
    });
  });

  group('SectionHeader', () {
    testWidgets('shows the action only when it has a callback', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        SectionHeader(
          title: 'Featured',
          actionLabel: 'See all',
          onAction: () => taps++,
        ),
      );
      await tester.tap(find.text('See all'));
      expect(taps, 1);

      await tester.pumpApp(const SectionHeader(title: 'Featured'));
      expect(find.byType(TextButton), findsNothing);
    });
  });

  testWidgets('LoadingView, Shimmer and AppLogo render', (tester) async {
    await tester.pumpApp(
      const Column(
        children: [
          AppLogo(size: 48),
          Shimmer(child: SkeletonBox(width: 100, height: 20)),
          Expanded(child: LoadingView(message: 'Loading')),
        ],
      ),
    );
    expect(find.text('Loading'), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.byType(SkeletonBox), findsOneWidget);
  });
}
