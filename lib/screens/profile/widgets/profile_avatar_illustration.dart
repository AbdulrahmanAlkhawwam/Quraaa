import 'package:flutter/material.dart';

/// Simple avatar illustration used inside the profile preview card.
///
/// Built from basic shapes so no external asset is required. The illustration
/// is approximately 170 logical pixels tall and aligned to the bottom center.
class ProfileAvatarIllustration extends StatelessWidget {
  const ProfileAvatarIllustration({super.key});

  static const double _height = 170;
  static const double _headSize = 72;
  static const double _bodyWidth = 132;
  static const double _bodyHeight = 86;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: _headSize,
            height: _headSize,
            decoration: const BoxDecoration(
              color: Color(0xFF243B18),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: _bodyWidth,
            height: _bodyHeight,
            decoration: const BoxDecoration(
              color: Color(0xFF243B18),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_bodyWidth / 2),
                topRight: Radius.circular(_bodyWidth / 2),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
