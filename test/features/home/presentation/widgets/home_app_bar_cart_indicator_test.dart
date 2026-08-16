import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/home/presentation/widgets/home_app_bar.dart';
import 'package:quraaa/shared/theme/app_colors.dart';

void main() {
  setUpAll(() {
    EasyLocalization.logger.enableLevels = const [];
  });

  Future<void> pumpAppBar(
    WidgetTester tester, {
    required bool hasCartItems,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: HomeAppBar(
            isGuest: false,
            hasCartItems: hasCartItems,
          ),
        ),
      ),
    );
  }

  BoxDecoration avatarDecoration(WidgetTester tester) {
    final Container avatar = tester.widget<Container>(
      find.byKey(const ValueKey<String>('home-profile-avatar')),
    );
    return avatar.decoration! as BoxDecoration;
  }

  testWidgets('hides all red cart indicators when the cart is empty', (
    WidgetTester tester,
  ) async {
    await pumpAppBar(tester, hasCartItems: false);

    expect(avatarDecoration(tester).border, isNull);
    expect(
      find.byKey(const ValueKey<String>('home-cart-avatar-dot')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('home-profile-avatar')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('home-cart-menu-dot')),
      findsNothing,
    );
  });

  testWidgets('shows both red cart indicators when the cart has items', (
    WidgetTester tester,
  ) async {
    await pumpAppBar(tester, hasCartItems: true);

    final Border border = avatarDecoration(tester).border! as Border;
    expect(border.top.color, AppColors.error500);
    expect(
      find.byKey(const ValueKey<String>('home-cart-avatar-dot')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('home-profile-avatar')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('home-cart-menu-dot')),
      findsOneWidget,
    );
  });
}
