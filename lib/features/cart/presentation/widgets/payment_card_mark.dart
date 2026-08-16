import 'package:flutter/material.dart';

class MastercardMark extends StatelessWidget {
  const MastercardMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 28,
      height: 17,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 1,
            top: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 15, height: 15),
            ),
          ),
          Positioned(
            right: 1,
            top: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFF79E1B),
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 15, height: 15),
            ),
          ),
        ],
      ),
    );
  }
}
