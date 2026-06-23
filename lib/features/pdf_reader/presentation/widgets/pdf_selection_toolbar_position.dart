import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';

class PdfSelectionToolbarPosition extends StatelessWidget {
  const PdfSelectionToolbarPosition({
    required this.selectedBounds,
    required this.pageSize,
    required this.child,
    super.key,
  });

  final Rect? selectedBounds;
  final Size pageSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Rect? bounds = selectedBounds;
    if (bounds == null) {
      return const SizedBox.shrink();
    }

    final double left = _clampDouble(
      bounds.left,
      AppSpacing.sm,
      math.max(AppSpacing.sm, pageSize.width - 174),
    );
    final double top = _clampDouble(
      bounds.top - 54,
      AppSpacing.sm,
      math.max(AppSpacing.sm, pageSize.height - 54),
    );

    return Positioned(
      left: left,
      top: top,
      child: child,
    );
  }

  double _clampDouble(double value, double min, double max) {
    if (max < min) {
      return min;
    }

    return value.clamp(min, max).toDouble();
  }
}
