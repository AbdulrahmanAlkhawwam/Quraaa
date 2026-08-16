import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/cart_summary.dart';
import 'cart_totals_card.dart';

enum PaymentInfoAction { addPaymentMethod, checkout }

class PaymentInfoBottomSheet extends StatefulWidget {
  const PaymentInfoBottomSheet({super.key, required this.summary});

  final CartSummary summary;

  static Future<PaymentInfoAction?> show(
    BuildContext context,
    CartSummary summary,
  ) {
    return showModalBottomSheet<PaymentInfoAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.34),
      builder: (BuildContext context) =>
          PaymentInfoBottomSheet(summary: summary),
    );
  }

  @override
  State<PaymentInfoBottomSheet> createState() => _PaymentInfoBottomSheetState();
}

class _PaymentInfoBottomSheetState extends State<PaymentInfoBottomSheet> {
  int? _selectedCardIndex;

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = (context.height * 0.72).clamp(520.0, 660.0);

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.radius28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.spacing24,
            AppSpacing.spacing24,
            AppSpacing.spacing24,
            AppSpacing.spacing18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CartTotalsCard(summary: widget.summary),
              const SizedBox(height: AppSpacing.spacing20),
              Text(
                LocalizationConstants.cartPaymentUsedCardsKey.tr(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: context.appTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing10),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.spacing8),
                  itemBuilder: (BuildContext context, int index) {
                    return _PaymentCardTile(
                      selected: _selectedCardIndex == index,
                      onTap: () => setState(() => _selectedCardIndex = index),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.spacing14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(PaymentInfoAction.addPaymentMethod),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.isDark
                        ? AppColors.primary300
                        : AppColors.libraryGreen,
                    side: BorderSide(color: context.appBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.radius28),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 24),
                  label: Text(
                    LocalizationConstants.cartPaymentAddMethodKey.tr(),
                    style: AppTextStyles.buttonSmall,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spacing16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _selectedCardIndex == null
                      ? null
                      : () => Navigator.of(
                            context,
                          ).pop(PaymentInfoAction.checkout),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary600,
                    disabledBackgroundColor: context.isDark
                        ? AppColors.outlineDark
                        : const Color(0xFFD8D8D8),
                    foregroundColor: AppColors.card,
                    disabledForegroundColor: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.radius28),
                    ),
                  ),
                  child: Text(
                    LocalizationConstants.cartPaymentNextKey.tr(),
                    style: AppTextStyles.buttonMedium,
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

class _PaymentCardTile extends StatelessWidget {
  const _PaymentCardTile({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        selected ? AppColors.primary600 : context.appBorder;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 64,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing16,
            vertical: AppSpacing.spacing8,
          ),
          decoration: BoxDecoration(
            color: context.appCard,
            borderRadius: BorderRadius.circular(AppRadius.radius12),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      LocalizationConstants.cartPaymentCardCountryKey.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.appTextSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing4),
                    Text(
                      '**** **** **** *125',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.appTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.spacing12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const _MastercardMark(),
                  const SizedBox(height: AppSpacing.spacing4),
                  Text(
                    '8/26',
                    style: AppTextStyles.caption.copyWith(
                      color: context.appTextTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MastercardMark extends StatelessWidget {
  const MastercardMark({super.key});

  @override
  Widget build(BuildContext context) => const _MastercardMark();
}

class _MastercardMark extends StatelessWidget {
  const _MastercardMark();

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
