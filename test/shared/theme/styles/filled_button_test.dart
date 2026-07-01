import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/shared/theme/app_colors.dart';
import 'package:quraaa/shared/theme/app_radius.dart';
import 'package:quraaa/shared/theme/app_spacing.dart';
import 'package:quraaa/shared/theme/styles/filled_button.dart';

void main() {
  group('filledButtonTheme', () {
    test(
      'resolves background and foreground colors from the color scheme',
      () {
        final theme = filledButtonTheme(lightColors);
        final style = theme.style!;

        expect(style.backgroundColor!.resolve({}), lightColors.primary);
        expect(style.foregroundColor!.resolve({}), lightColors.onPrimary);
      },
    );

    test('adapts colors for the dark color scheme', () {
      final theme = filledButtonTheme(darkColors);
      final style = theme.style!;

      expect(style.backgroundColor!.resolve({}), darkColors.primary);
      expect(style.foregroundColor!.resolve({}), darkColors.onPrimary);
    });

    test('uses the correct minimum size and padding', () {
      final theme = filledButtonTheme(lightColors);
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
      final theme = filledButtonTheme(lightColors);
      final style = theme.style!;
      final shape = style.shape!.resolve({}) as RoundedRectangleBorder;

      expect(shape.borderRadius, BorderRadius.circular(AppRadius.radius32));
    });

    test('applies disabled colors from the color scheme', () {
      final theme = filledButtonTheme(lightColors);
      final style = theme.style!;
      const disabledStates = {WidgetState.disabled};

      expect(
        style.backgroundColor!.resolve(disabledStates),
        AppColors.surface,
      );
      expect(
        style.foregroundColor!.resolve(disabledStates),
        lightColors.onSurface.withAlpha(97),
      );
    });
  });
}
