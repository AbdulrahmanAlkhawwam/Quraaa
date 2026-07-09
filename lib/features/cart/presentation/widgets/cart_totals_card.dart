import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/cart_summary.dart';

class CartTotalsCard extends StatelessWidget {
  const CartTotalsCard({required this.summary, super.key});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    final double scale = context.compactFeatureScale;

    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(
        20 * scale,
        20 * scale,
        20 * scale,
        18 * scale,
      ),
      decoration: BoxDecoration(
        color: context.appSubtleSurface,
        borderRadius: BorderRadius.circular(17 * scale),
      ),
      child: Column(
        children: <Widget>[
          _TotalRow(
            label: LocalizationConstants.cartSubtotalKey.tr(),
            value: _money(summary.subtotal),
            scale: scale,
          ),
          SizedBox(height: 13 * scale),
          _TotalRow(
            label: LocalizationConstants.cartFatKey.tr(),
            value: '${summary.fatPercent.toStringAsFixed(0)}%',
            scale: scale,
          ),
          SizedBox(height: 13 * scale),
          _TotalRow(
            label: LocalizationConstants.cartDeliveryKey.tr(),
            value: _money(summary.delivery),
            scale: scale,
          ),
          SizedBox(height: 13 * scale),
          _TotalRow(
            label: LocalizationConstants.cartDiscountKey.tr(),
            value: '${summary.discountPercent.toStringAsFixed(0)}%',
            scale: scale,
          ),
          SizedBox(height: 14 * scale),
          Divider(
            height: 1,
            thickness: 1,
            color: context.appBorder,
          ),
          SizedBox(height: 14 * scale),
          _TotalRow(
            label: LocalizationConstants.cartTotalKey.tr(),
            value: _money(summary.total),
            isTotal: true,
            scale: scale,
          ),
        ],
      ),
    );
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.scale,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final double scale;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = isTotal
        ? AppTextStyles.bodyLarge.copyWith(fontSize: 22 * scale)
        : AppTextStyles.bodyMedium.copyWith(fontSize: 16 * scale);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: baseStyle.copyWith(
              color: isTotal ? context.appTextPrimary : context.appTextSecondary,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: baseStyle.copyWith(
            color: isTotal ? context.appTextPrimary : context.appTextSecondary,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

