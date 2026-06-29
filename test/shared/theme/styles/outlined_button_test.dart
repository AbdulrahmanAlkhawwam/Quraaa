import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/shared/theme/app_colors.dart';
import 'package:quraaa/shared/theme/app_radius.dart';
import 'package:quraaa/shared/theme/app_spacing.dart';
import 'package:quraaa/shared/theme/styles/outlined_button.dart';

void main() {
  group('outlinedButtonTheme', () {
    test(
      'resolves foreground and background colors from the color scheme',
      () {
        final theme = outlinedButtonTheme(lightColors);
        final style = theme.style!;

        expect(style.foregroundColor!.resolve({}), lightColors.onSurface);
        expect(style.backgroundColor!.resolve({}), AppColors.card);
      },
    );

    test('adapts colors for the dark color scheme', () {
      final theme = outlinedButtonTheme(darkColors);
      final style = theme.style!;

      expect(style.foregroundColor!.resolve({}), darkColors.onSurface);
      expect(style.backgroundColor!.resolve({}), AppColors.card);
    });

    test('uses the correct outline color and disabled outline color', () {
      final theme = outlinedButtonTheme(lightColors);
      final style = theme.style!;
      final side = style.side!.resolve({}) as BorderSide;

      expect(side.color, lightColors.outline);
      expect(side.width, 1);

      final disabledSide =
          style.side!.resolve({WidgetState.disabled}) as BorderSide;
      expect(disabledSide.color, lightColors.onSurface.withAlpha(31));
    });

    test('uses the correct minimum size and padding', () {
      final theme = outlinedButtonTheme(lightColors);
      final style = theme.style!;

      expect(
        style.minimumSize!.resolve({}),
        const Size(double.infinity, AppSpacing.spacing48),
      );
      expect(
        style.padding!.resolve({}),
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing16,
          vertical: AppSpacing.spacing12,
        ),
      );
    });

    test('uses a rounded rectangle shape with radius 32', () {
      final theme = outlinedButtonTheme(lightColors);
      final style = theme.style!;
      final shape = style.shape!.resolve({}) as RoundedRectangleBorder;

      expect(shape.borderRadius, BorderRadius.circular(AppRadius.radius32));
    });
  });
}
