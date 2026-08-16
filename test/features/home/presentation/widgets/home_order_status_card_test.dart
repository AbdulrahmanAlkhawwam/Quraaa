import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/home/presentation/widgets/home_order_status_card.dart';

void main() {
  setUpAll(() {
    EasyLocalization.logger.enableLevels = const [];
  });

  testWidgets('defaults to the on-door preview state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeOrderStatusCard(),
        ),
      ),
    );

    final HomeOrderStatusCard card = tester.widget<HomeOrderStatusCard>(
      find.byType(HomeOrderStatusCard),
    );
    expect(card.status, HomeOrderStatus.onDoor);
    expect(find.byIcon(Icons.pending_actions_outlined), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    expect(find.byIcon(Icons.door_front_door_outlined), findsOneWidget);
  });

  for (final HomeOrderStatus status in HomeOrderStatus.values) {
    testWidgets('renders the ${status.name} state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeOrderStatusCard(status: status),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey<String>('home-order-status-card')),
        findsOneWidget,
      );
    });
  }

  testWidgets('renders the default state in RTL without overflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: HomeOrderStatusCard(),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
