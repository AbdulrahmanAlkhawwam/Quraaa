import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quraaa/shared/extensions/app_context.dart';
import 'package:quraaa/shared/models/message.dart';
import 'package:quraaa/shared/widgets/app_layout.dart';

void main() {
  group('AppLayout', () {
    testWidgets('renders with expandContent true and Expanded child', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppLayout(
            expandContent: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Top'),
                Expanded(child: Container()),
                const Text('Bottom'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
    });

    testWidgets('renders with header and expandContent true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppLayout(
            expandContent: true,
            header: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_back),
                ),
                const Expanded(child: Text('Title')),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Content'),
                Expanded(child: Container()),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('renders with default expandContent false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppLayout(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text('Button 1'), Text('Button 2')],
            ),
          ),
        ),
      );

      expect(find.text('Button 1'), findsOneWidget);
      expect(find.text('Button 2'), findsOneWidget);
    });

    testWidgets('keeps SnackBar inside the visible Scaffold', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppLayout(
            child: Builder(
              builder: (BuildContext context) {
                return FilledButton(
                  onPressed: () {
                    context.showErrorSnackBar(
                      message: const Message(
                        title: 'Login failed',
                        value: 'Invalid credentials',
                      ),
                    );
                  },
                  child: const Text('Show error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show error'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final Rect scaffoldRect = tester.getRect(find.byType(Scaffold));
      final Rect snackBarRect = tester.getRect(find.byType(SnackBar));
      final SnackBar snackBar = tester.widget<SnackBar>(find.byType(SnackBar));

      expect(snackBarRect.top, greaterThanOrEqualTo(scaffoldRect.top));
      expect(snackBarRect.bottom, lessThanOrEqualTo(scaffoldRect.bottom));
      expect(find.text('Login failed'), findsOneWidget);
      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(snackBar.duration, const Duration(seconds: 6));
      expect(snackBar.showCloseIcon, isTrue);
    });
  });
}
