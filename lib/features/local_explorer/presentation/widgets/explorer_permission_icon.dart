import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ExplorerPermissionIcon extends StatelessWidget {
  const ExplorerPermissionIcon({super.key});

  static const Color _iconColor = Color(0xFF69C052);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 72,
      child: Center(
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedDoorOpen,
          color: _iconColor,
          size: 64,
        ),
      ),
    );
  }
}
