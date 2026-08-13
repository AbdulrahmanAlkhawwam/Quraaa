import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_summary.dart';
import '../bloc/cart_bloc.dart';
import 'add_payment_card_bottom_sheet.dart';
import 'cart_item_tile.dart';
import 'cart_totals_card.dart';
import 'payment_info_bottom_sheet.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  Future<void> _openPaymentFlow(
    BuildContext context,
    CartSummary summary,
  ) async {
    final bool? openAddCard = await PaymentInfoBottomSheet.show(
      context,
      summary,
    );
    if (openAddCard == true && context.mounted) {
      await AddPaymentCardBottomSheet.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color background = context.appCard;
    final Brightness overlayBrightness = context.isDark
        ? Brightness.light
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: background,
        statusBarIconBrightness: overlayBrightness,
        systemNavigationBarColor: background,
        systemNavigationBarIconBrightness: overlayBrightness,
      ),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(1)),
        child: Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: BlocBuilder<CartBloc, CartState>(
              builder: (BuildContext context, CartState state) {
                if (state is CartLoading || state is CartInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary600,
                    ),
                  );
                }

                if (state is CartFailure) {
                  return Center(
                    child: Text(
                      state.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error500,
                      ),
                    ),
                  );
                }

                if (state is! CartLoaded) {
                  return const SizedBox.shrink();
                }

                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool hasUnavailableItem = state.summary.items.any(
                      (CartItem item) => !item.isAvailable,
                    );
                    final double horizontal = (constraints.maxWidth * 0.05)
                        .clamp(18.0, 24.0);

                    return Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        horizontal,
                        AppSpacing.spacing8,
                        horizontal,
                        AppSpacing.spacing12,
                      ),
                      child: Column(
                        children: <Widget>[
                          _CartPageHeader(onBack: context.back),
                          const SizedBox(height: AppSpacing.spacing16),
                          Expanded(
                            child: state.summary.items.isEmpty
                                ? const _EmptyCartState()
                                : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: state.summary.items.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final CartItem item =
                                              state.summary.items[index];
                                          return CartItemTile(
                                            item: item,
                                            showDivider:
                                                index !=
                                                state.summary.items.length - 1,
                                            onIncrease: () =>
                                                context.read<CartBloc>().add(
                                                  CartQuantityIncreased(item),
                                                ),
                                            onDecrease: () =>
                                                context.read<CartBloc>().add(
                                                  CartQuantityDecreased(item),
                                                ),
                                            onRemove: () => context
                                                .read<CartBloc>()
                                                .add(CartItemRemoved(item.id)),
                                          );
                                        },
                                  ),
                          ),
                          if (state.summary.items.isNotEmpty) ...<Widget>[
                            const SizedBox(height: AppSpacing.spacing12),
                            CartTotalsCard(summary: state.summary),
                            const SizedBox(height: AppSpacing.spacing16),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                onPressed: hasUnavailableItem
                                    ? null
                                    : () => _openPaymentFlow(
                                        context,
                                        state.summary,
                                      ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary600,
                                  foregroundColor: AppColors.card,
                                  disabledBackgroundColor: context.appBorder,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.radius28,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  LocalizationConstants.cartCheckoutKey.tr(),
                                  style: AppTextStyles.buttonMedium,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              'assets/illustrations/empty_cart.svg',
              width: 90.643,
              height: 120,
              semanticsLabel: LocalizationConstants.cartEmptyKey.tr(),
            ),
            const SizedBox(height: AppSpacing.spacing24),
            Text(
              LocalizationConstants.cartEmptyTitleKey.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: context.appTextPrimary,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 334),
              child: Text(
                LocalizationConstants.cartEmptyDescriptionKey.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.appTextPrimary.withValues(alpha: 0.48),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartPageHeader extends StatelessWidget {
  const _CartPageHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            icon: HugeIcon(
              icon: context.isRTL
                  ? HugeIcons.strokeRoundedArrowRight01
                  : HugeIcons.strokeRoundedArrowLeft01,
              color: context.isDark
                  ? AppColors.primary300
                  : AppColors.libraryGreen,
              size: 23,
            ),
          ),
          const SizedBox(width: AppSpacing.spacing8),
          Expanded(
            child: Text(
              LocalizationConstants.cartTitleKey.tr(),
              style: AppTextStyles.titleLarge.copyWith(
                color: context.appTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
