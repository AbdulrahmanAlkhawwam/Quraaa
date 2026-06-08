import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum _ButtonVariant { primary, secondary }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final _ButtonVariant variant;
  final bool isLoading;
  const CustomButton._({
    required this.text,
    required this.onPressed,
    required this.variant,
    this.isLoading = false,
    super.key,
  });

  /// Primary button – solid background, white text.
  factory CustomButton.primary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) =>
      CustomButton._(
          text: text,
          onPressed: onPressed,
          variant: _ButtonVariant.primary,
          isLoading: isLoading);

  /// Secondary button – transparent background, border and primary text color.
  factory CustomButton.secondary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) =>
      CustomButton._(
          text: text,
          onPressed: onPressed,
          variant: _ButtonVariant.secondary,
          isLoading: isLoading);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _buildButtonStyle();
    final child = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Text(
            text,
            style: AppTextStyles.buttonMedium,
          );
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: child,
      ),
    );
  }

  ButtonStyle _buildButtonStyle() {
    // Base shape – same radius for both variants.
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius32),
    );
    // Overlay colors for hover/pressed states.
    final overlay = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return variant == _ButtonVariant.primary
            ? AppColors.primary800
            : AppColors.primary200.withOpacity(0.2);
      }
      if (states.contains(WidgetState.hovered)) {
        return variant == _ButtonVariant.primary
            ? AppColors.primary700
            : AppColors.primary200.withOpacity(0.1);
      }
      return null;
    });

    if (variant == _ButtonVariant.primary) {
      return ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary600,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.buttonMedium,
        shape: shape,
        elevation: 0,
        padding: EdgeInsets.zero,
      ).copyWith(overlayColor: overlay);
    } else {
      // Secondary – transparent with border.
      return ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        textStyle: AppTextStyles.buttonMedium,
        shape: shape,
        elevation: 0,
        side: const BorderSide(color: AppColors.primary200),
        padding: EdgeInsets.zero,
      ).copyWith(overlayColor: overlay);
    }
  }
}
