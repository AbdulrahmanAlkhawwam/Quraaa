import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/message.dart';

extension AppNavigation on BuildContext {
  Future<T?> pushTo<T extends Object?>(
    String route, {
    Object? extra,
  }) {
    return GoRouter.of(this).push<T>(route, extra: extra);
  }

  void goTo(
    String route, {
    Object? extra,
  }) {
    GoRouter.of(this).go(route, extra: extra);
  }

  // Future<T?> replaceWith<T extends Object?>(
  //   String route, {
  //   Object? extra,
  // }) {
  //   return pushReplacement<T, T>(route, extra: extra);
  // }

  void back<T extends Object?>([T? result]) => pop(result);
}

extension AppThemeX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  TextTheme get textTheme => Theme.of(this).textTheme;
}

extension AppResponsive on BuildContext {
  double get height => MediaQuery.sizeOf(this).height;

  double get width => MediaQuery.sizeOf(this).width;

  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  double get bottomInsets => MediaQuery.viewInsetsOf(this).bottom;
}

extension AppDirectionality on BuildContext {
  TextDirection get textDirection => Directionality.of(this);

  bool get isRTL => textDirection == TextDirection.rtl;

  bool get isLTR => textDirection == TextDirection.ltr;
}

extension AppSnackbar on BuildContext {
  void showSuccessSnackBar({Message? message}) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.primaryContainer,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary),
        ),
        duration: const Duration(milliseconds: 2500),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedBookCheck,
                  color: colors.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  message?.title ?? '',
                  textAlign: TextAlign.start,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message?.value ?? '',
              textAlign: TextAlign.start,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showErrorSnackBar({Message? message}) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.errorContainer,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error),
        ),
        duration: const Duration(milliseconds: 2500),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedAlertCircle,
                  color: colors.error,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  message?.title ?? '',
                  textAlign: TextAlign.start,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message?.value ?? '',
              textAlign: TextAlign.start,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
