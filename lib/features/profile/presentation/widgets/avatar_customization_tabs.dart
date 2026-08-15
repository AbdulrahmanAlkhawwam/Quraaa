import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

/// Avatar customization strip. Only the background option is enabled for now.
class AvatarCustomizationTabs extends StatelessWidget {
  const AvatarCustomizationTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  static const List<List<List<dynamic>>> _featureIcons = <List<List<dynamic>>>[
    HugeIcons.strokeRoundedUser,
    HugeIcons.strokeRoundedUserAccount,
    HugeIcons.strokeRoundedUser,
    HugeIcons.strokeRoundedShirt01,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE7ECE4)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 44,
            child: Material(
              color: AppColors.avatarTabSelected,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.radius10),
              ),
              child: InkWell(
                onTap: () => onTabSelected(0),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.radius10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const _BackgroundPatternIcon(),
                    const SizedBox(width: AppSpacing.spacing12),
                    Flexible(
                      child: Text(
                        LocalizationConstants.avatarTabBackgroundKey.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primary600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (int index = 0; index < _featureIcons.length; index++)
            Expanded(
              flex: 14,
              child: IgnorePointer(
                child: Center(
                  child: index == 2
                      ? const _MustacheIcon()
                      : HugeIcon(
                          icon: _featureIcons[index],
                          color: AppColors.editProfileTitle,
                          size: index == 3 ? 27 : 25,
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BackgroundPatternIcon extends StatelessWidget {
  const _BackgroundPatternIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(24),
      painter: _BackgroundPatternPainter(),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final RRect bounds = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(6),
    );
    canvas.drawRRect(
      bounds,
      Paint()
        ..color = AppColors.primary50
        ..style = PaintingStyle.fill,
    );
    canvas.save();
    canvas.clipRRect(bounds);

    final Paint stripe = Paint()
      ..color = AppColors.primary600
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (double start = -size.height; start < size.width; start += 5) {
      canvas.drawLine(
        Offset(start, size.height),
        Offset(start + size.height, 0),
        stripe,
      );
    }
    canvas.restore();
    canvas.drawRRect(
      bounds,
      Paint()
        ..color = AppColors.primary600
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MustacheIcon extends StatelessWidget {
  const _MustacheIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(29, 20),
      painter: _MustachePainter(),
    );
  }
}

class _MustachePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.editProfileTitle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path()
      ..moveTo(size.width / 2, 9)
      ..cubicTo(11, 4, 10, 13, 4, 12)
      ..cubicTo(7, 19, 13, 18, size.width / 2, 12)
      ..cubicTo(16, 18, 22, 19, 25, 12)
      ..cubicTo(19, 13, 18, 4, size.width / 2, 9);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
