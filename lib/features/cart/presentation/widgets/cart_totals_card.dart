import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/cart_summary.dart';

class CartTotalsCard extends StatelessWidget {
  const CartTotalsCard({required this.summary, super.key});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    final double scale =
        (MediaQuery.sizeOf(context).width / 520).clamp(0.78, 0.9).toDouble();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        20 * scale,
        20 * scale,
        18 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(17 * scale),
      ),
      child: Column(
        children: <Widget>[
          _TotalRow(
            label: 'Sub Total',
            value: _money(summary.subtotal),
            scale: scale,
          ),
          SizedBox(height: 13 * scale),
          _TotalRow(
            label: 'Fat',
            value: '${summary.fatPercent.toStringAsFixed(0)}%',
            scale: scale,
          ),
          SizedBox(height: 13 * scale),
          _TotalRow(
            label: 'Delivery',
            value: _money(summary.delivery),
            scale: scale,
          ),
          SizedBox(height: 13 * scale),
          _TotalRow(
            label: 'Discount',
            value: '${summary.discountPercent.toStringAsFixed(0)}%',
            scale: scale,
          ),
          SizedBox(height: 14 * scale),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFDDE8D7),
          ),
          SizedBox(height: 14 * scale),
          _TotalRow(
            label: 'Total',
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
              color: isTotal ? const Color(0xFF25303D) : const Color(0xFF8294A9),
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: baseStyle.copyWith(
            color: isTotal ? const Color(0xFF25303D) : const Color(0xFF8294A9),
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

