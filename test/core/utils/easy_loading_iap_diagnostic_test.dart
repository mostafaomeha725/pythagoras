import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/utils/easy_loading.dart';

void main() {
  testWidgets(
    'signed transaction is opt-in and response copy excludes it',
    (tester) async {
      const signedTransaction = 'current-purchase-server-verification-data';
      final copiedValues = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedValues.add(
              (call.arguments as Map<Object?, Object?>)['text']! as String,
            );
          }
          return null;
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showVerificationDiagnostic(
                  context,
                  statusCode: 422,
                  responseBody: '{"message":"verification rejected"}',
                  productId: 'course.product.21',
                  targetType: 'course',
                  contentId: 21,
                  signedTransaction: signedTransaction,
                ),
                child: const Text('Open diagnostic'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open diagnostic'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(signedTransaction), findsNothing);
      expect(find.text('course.product.21'), findsOneWidget);
      expect(find.text('target type: course\ncontentId: 21'), findsOneWidget);

      await tester.tap(find.byTooltip('Copy response'));
      await tester.pump();
      expect(copiedValues, hasLength(1));
      expect(copiedValues.single, contains('HTTP Status Code: 422'));
      expect(
        copiedValues.single,
        contains('{"message":"verification rejected"}'),
      );
      expect(copiedValues.single, isNot(contains(signedTransaction)));
      expect(copiedValues.single, isNot(contains('course.product.21')));

      final revealButton = find.byTooltip('Reveal signedTransaction');
      await tester.ensureVisible(revealButton);
      await tester.pump();
      await tester.tap(revealButton);
      await tester.pump();
      expect(find.text(signedTransaction), findsOneWidget);

      final copyTransactionButton = find.byTooltip('Copy signedTransaction');
      await tester.ensureVisible(copyTransactionButton);
      await tester.pump();
      await tester.tap(copyTransactionButton);
      await tester.pump();
      expect(copiedValues, hasLength(2));
      expect(copiedValues.last, signedTransaction);
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );
}
