import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/shared/shared.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    required ThemeData theme,
  }) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: AppTextField(
            controller: controller,
            hintText: 'Password',
            textInputAction: TextInputAction.done,
          ),
        ),
      ),
    );
  }

  testWidgets('uses the light auth field colors in light mode', (
    WidgetTester tester,
  ) async {
    await pumpField(tester, theme: AppTheme.light());

    final EditableText editable = tester.widget<EditableText>(
      find.byType(EditableText),
    );
    final InputDecorator decorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );

    expect(editable.style.color, AppColors.textPrimary);
    expect(decorator.decoration.fillColor, AppColors.card);
    expect(
      (decorator.decoration.enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.primary100,
    );
  });

  testWidgets('uses a dark surface and readable text in dark mode', (
    WidgetTester tester,
  ) async {
    await pumpField(tester, theme: AppTheme.dark());

    final EditableText editable = tester.widget<EditableText>(
      find.byType(EditableText),
    );
    final InputDecorator decorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );

    expect(editable.style.color, AppColors.textPrimaryDark);
    expect(decorator.decoration.fillColor, AppColors.surfaceDark);
    expect(
      (decorator.decoration.enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.outlineDark,
    );
    expect(decorator.decoration.hintStyle?.color, AppColors.textTertiaryDark);
  });
}
