import 'package:flutter/material.dart';

class ExplorerPermissionHeader extends StatelessWidget {
  const ExplorerPermissionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF133D1E),
            Color(0xFF102B17),
            Color(0xFF07180E),
          ],
        ),
      ),
      child: CustomPaint(
        child: SizedBox.expand(),
      ),
    );
  }
}

