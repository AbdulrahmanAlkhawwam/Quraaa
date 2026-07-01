import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/shared/theme/app_colors.dart';
import 'package:quraaa/shared/theme/app_spacing.dart';
import 'package:quraaa/shared/theme/styles/text_button.dart';

void main() {
  group('textButtonTheme', () {
    test('resolves foreground color from the color scheme', () {
      final theme = textButtonTheme(lightColors);
      final style = theme.style!;

      expect(style.foregroundColor!.resolve({}), lightColors.primary);
    });

    test('adapts foreground color for the dark color scheme', () {
      final theme = textButtonTheme(darkColors);
      final style = theme.style!;

      expect(style.foregroundColor!.resolve({}), darkColors.primary);
    });

    test('uses the correct padding', () {
      final theme = textButtonTheme(lightColors);
      final style = theme.style!;

      expect(
        style.padding!.resolve({}),
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing12,
          vertical: AppSpacing.spacing8,
        ),
      );
    });

    test('applies disabled foreground color from the color scheme', () {
      final theme = textButtonTheme(lightColors);
      final style = theme.style!;
      const disabledStates = {WidgetState.disabled};

      expect(
        style.foregroundColor!.resolve(disabledStates),
        lightColors.onSurface.withAlpha(97),
      );
    });

    test('applies theme-aware overlay colors for pressed and hovered states', () {
      final theme = textButtonTheme(lightColors);
      final style = theme.style!;

      expect(
        style.overlayColor!.resolve({WidgetState.pressed}),
        lightColors.primary.withAlpha(31),
      );
      expect(
        style.overlayColor!.resolve({WidgetState.hovered}),
        lightColors.primary.withAlpha(20),
      );
    });
  });
}
