import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/cart_summary.dart';

class CartHeader extends StatelessWidget {
  const CartHeader({required this.summary, super.key});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    final double scale = context.compactFeatureScale;

    return SizedBox(
      height: 48 * scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              'Hi , ${summary.userName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.libraryGreen,
                fontSize: 28 * scale,
                fontWeight: FontWeight.w500,
                height: 1.05,
              ),
            ),
          ),
          SizedBox(width: 14 * scale),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.primary100,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: SizedBox(
                width: 46 * scale,
                height: 46 * scale,
                child: CachedNetworkImage(
                  imageUrl: summary.avatarUrl,
                  fit: BoxFit.cover,
                  placeholder: (BuildContext context, String url) {
                    return const ColoredBox(color: AppColors.primary100);
                  },
                  errorWidget: (BuildContext context, String url, Object error) {
                    return Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedUser,
                        color: AppColors.primary600,
                        size: 23 * scale,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

