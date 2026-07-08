import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/shared.dart';

class AssistantSparkle extends StatelessWidget {
  const AssistantSparkle({required this.scale, super.key});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return HugeIcon(
      icon: HugeIcons.strokeRoundedSparkles,
      color: AppColors.primary600,
      size: 66 * scale,
    );
  }
}
