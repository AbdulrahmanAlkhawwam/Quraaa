import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

class AssistantHeader extends StatelessWidget {
  const AssistantHeader({required this.scale, super.key});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final Color titleColor =
        context.isDark ? AppColors.primary300 : AppColors.libraryGreen;

    return SizedBox(
      height: 46 * scale,
      child: Row(
        children: <Widget>[
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.primary100,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: SizedBox(
                width: 42 * scale,
                height: 42 * scale,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=160&q=80',
                  fit: BoxFit.cover,
                  placeholder: (BuildContext context, String url) {
                    return const ColoredBox(color: AppColors.primary100);
                  },
                  errorWidget: (
                    BuildContext context,
                    String url,
                    Object error,
                  ) {
                    return Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedUser,
                        color: AppColors.primary600,
                        size: 21 * scale,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 26 * scale),
          Expanded(
            child: Text(
              LocalizationConstants.assistantGreetingKey.tr(
                namedArgs: const <String, String>{'name': 'Abdulrahman'},
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h3.copyWith(
                color: titleColor,
                fontSize: 27 * scale,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
