import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class SettingsActionGroup extends StatelessWidget {
  const SettingsActionGroup({
    super.key,
    required this.children,
    this.backgroundColor = AppColors.card,
    this.borderColor = AppColors.primary100,
    this.borderRadius = AppRadius.radius32,
  });

  final List<Widget> children;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildChildren(),
        ),
      ),
    );
  }

  List<Widget> _buildChildren() {
    final List<Widget> result = <Widget>[];
    for (int index = 0; index < children.length; index++) {
      result.add(children[index]);
      final bool isLast = index == children.length - 1;
      if (!isLast) {
        result.add(
          const Divider(
            height: 1,
            thickness: 1,
            indent: AppSpacing.spacing20,
            endIndent: AppSpacing.spacing20,
            color: AppColors.primary100,
          ),
        );
      }
    }
    return result;
  }
}
