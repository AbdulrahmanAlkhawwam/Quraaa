import 'package:flutter/material.dart';

class ExplorerPermissionProgressBar extends StatelessWidget {
  const ExplorerPermissionProgressBar({super.key});

  static const double _height = 3;
  static const double _progress = 0.225;
  static const Color _activeColor = Color(0xFF69C052);
  static const Color _trackColor = Color(0xFFEAF7E8);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_height),
      child: ColoredBox(
        color: _trackColor,
        child: SizedBox(
          height: _height,
          width: double.infinity,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: _progress,
              heightFactor: 1,
              child: const ColoredBox(color: _activeColor),
            ),
          ),
        ),
      ),
    );
  }
}
