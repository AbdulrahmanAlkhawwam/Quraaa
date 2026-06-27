import 'package:flutter/material.dart';

class ProgressOverlay extends StatelessWidget {
  const ProgressOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        const Positioned(
          left: 0,
          top: 0,
          right: 0,
          child: LinearProgressIndicator(minHeight: 2),
        ),
      ],
    );
  }
}
