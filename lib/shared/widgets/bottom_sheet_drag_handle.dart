import 'package:flutter/material.dart';

import '../extensions/app_context.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_radius.dart';

/// Reusable drag handle shown at the top of modal bottom sheets.
class BottomSheetDragHandle extends StatelessWidget {
  const BottomSheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.dragHandleWidth,
      height: AppDimensions.dragHandleHeight,
      decoration: BoxDecoration(
        color: context.appTextTertiary.withAlpha(76),
        borderRadius: BorderRadius.circular(AppRadius.radius2),
      ),
    );
  }
}
