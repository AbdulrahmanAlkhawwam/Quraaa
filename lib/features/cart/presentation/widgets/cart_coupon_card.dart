import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

class CartCouponCard extends StatelessWidget {
  const CartCouponCard({
    required this.code,
    required this.applied,
    required this.onApply,
    super.key,
  });

  final String code;
  final bool applied;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final double scale = context.compactFeatureScale;

    return SizedBox(
      width: double.infinity,
      height: 72 * scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.circular(36 * scale),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            29 * scale,
            9 * scale,
            10 * scale,
            9 * scale,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary600,
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                width: 108 * scale,
                height: 54 * scale,
                child: FilledButton(
                  onPressed: onApply,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary300,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28 * scale),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    applied ? 'Applied' : 'Apply',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

