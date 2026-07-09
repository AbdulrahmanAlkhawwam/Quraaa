import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/cart_item.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    required this.item,
    required this.showDivider,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    super.key,
  });

  final CartItem item;
  final bool showDivider;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final double scale = context.compactFeatureScale;
    final Color titleColor =
        context.isDark ? AppColors.primary300 : AppColors.libraryGreen;
    final Color subtitleColor =
        context.isDark ? AppColors.primary400 : AppColors.forestGreen;

    return Column(
      children: <Widget>[
        SizedBox(
          height: 116 * scale,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _BookCover(imageUrl: item.imageUrl, scale: scale),
              SizedBox(width: 14 * scale),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 2 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: titleColor,
                          fontSize: 21 * scale,
                          fontWeight: FontWeight.w500,
                          height: 1.12,
                        ),
                      ),
                      SizedBox(height: 3 * scale),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: subtitleColor,
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20 * scale),
                        child: Text(
                          item.fileSize,
                          style: AppTextStyles.caption.copyWith(
                            color: context.appTextTertiary,
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              SizedBox(
                width: 105 * scale,
                height: 95 * scale,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: IconButton(
                        tooltip: LocalizationConstants.cartRemoveKey.tr(),
                        onPressed: onRemove,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(
                          width: 35 * scale,
                          height: 35 * scale,
                        ),
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          color: const Color(0xFFFF303A),
                          size: 28 * scale,
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: _QuantityControl(
                        quantity: item.quantity,
                        onIncrease: onIncrease,
                        onDecrease: onDecrease,
                        scale: scale,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: context.appBorder,
          ),
      ],
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.imageUrl, required this.scale});

  final String imageUrl;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4 * scale),
      child: SizedBox(
        width: 64 * scale,
        height: 95 * scale,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (BuildContext context, String url) {
            return const ColoredBox(color: AppColors.primary100);
          },
          errorWidget: (BuildContext context, String url, Object error) {
            return ColoredBox(
              color: AppColors.primary100,
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedBookOpen01,
                  color: AppColors.primary600,
                  size: 27 * scale,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.scale,
  });

  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _QuantityButton(
          icon: HugeIcons.strokeRoundedMinusSign,
          onTap: onDecrease,
          scale: scale,
        ),
        SizedBox(
          width: 34 * scale,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
              fontSize: 18 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _QuantityButton(
          icon: HugeIcons.strokeRoundedPlusSign,
          onTap: onIncrease,
          scale: scale,
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.scale,
  });

  final List<List<dynamic>> icon;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.isDark ? AppColors.primary800 : const Color(0xFFB7E3A6),
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 34 * scale,
          height: 34 * scale,
          child: Center(
            child: HugeIcon(
              icon: icon,
              color: AppColors.primary600,
              size: 19 * scale,
            ),
          ),
        ),
      ),
    );
  }
}

