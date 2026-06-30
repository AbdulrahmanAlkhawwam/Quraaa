import 'package:flutter/material.dart';

abstract class AppShadows {
  static const List<BoxShadow> elevation1 = <BoxShadow>[
    BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Color(0x14000000)),
  ];

  static const List<BoxShadow> elevation2 = <BoxShadow>[
    BoxShadow(
      blurRadius: 8,
      offset: Offset(0, 2),
      color: Color(0x28000000),
    ),
  ];

  static List<BoxShadow> avatarGlow(Color color) => <BoxShadow>[
        BoxShadow(
          color: color.withAlpha(50),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> pinFocused(Color color) => <BoxShadow>[
        BoxShadow(
          color: color.withAlpha(40),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
