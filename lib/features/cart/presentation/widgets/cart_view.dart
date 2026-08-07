import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../orders/orders.dart';
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
    final PaymentInfoAction? action = await PaymentInfoBottomSheet.show(
      context,
      summary,
    );
    if (!context.mounted || action == null) return;
    switch (action) {
      case PaymentInfoAction.addPaymentMethod:
        await AddPaymentCardBottomSheet.show(context);
      case PaymentInfoAction.checkout:
        await _startCheckout(context);
    }
  }

  Future<void> _startCheckout(BuildContext context) async {
    final CheckoutCubit cubit = context.read<CheckoutCubit>();
    await cubit.startCheckout();
    if (!context.mounted) return;

    final CheckoutState state = cubit.state;
    switch (state) {
      case CheckoutReady(checkout: final checkout):
        final Uri? uri = Uri.tryParse(checkout.checkoutUrl);
        bool opened = false;
        if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
          try {
            opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {}
        }
        if (!opened && context.mounted) {
          context.showResolvedErrorSnackBar(
            LocalizationConstants.cartCheckoutOpenFailedKey.tr(),
          );
        }
      case CheckoutFailure(error: final error):
        context.showResolvedErrorSnackBar(error);
      case CheckoutInitial() || CheckoutLoading():
        break;
    }
    cubit.reset();
  }

  @override
  Widget build(BuildContext context) {
    final Color background = context.appCard;
    final CheckoutState checkoutState = context.watch<CheckoutCubit>().state;
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

                final bool isEmpty = state.summary.items.isEmpty;

                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
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
                          _CartPageHeader(
                            onBack: context.back,
                            showClearAction: !isEmpty,
                            onClear: state.isUpdating
                                ? null
                                : () => context.read<CartBloc>().add(
                                    const CartCleared(),
                                  ),
                          ),
                          const SizedBox(height: AppSpacing.spacing16),
                          Expanded(
                            child: isEmpty
                                ? const _EmptyCartContent()
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
                          if (!isEmpty) ...<Widget>[
                            const SizedBox(height: AppSpacing.spacing12),
                            CartTotalsCard(summary: state.summary),
                            const SizedBox(height: AppSpacing.spacing16),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                onPressed: checkoutState is CheckoutLoading
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
                                child: checkoutState is CheckoutLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.card,
                                        ),
                                      )
                                    : Text(
                                        LocalizationConstants.cartCheckoutKey
                                            .tr(),
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

class _EmptyCartContent extends StatelessWidget {
  const _EmptyCartContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, 28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.leafGreen.withValues(alpha: 0.18),
                      blurRadius: 36,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedShoppingCart01,
                  color: AppColors.leafGreen,
                  size: 76,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing24),
              Text(
                LocalizationConstants.cartEmptyTitleKey.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.h4.copyWith(
                  color: context.appTextPrimary,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Text(
                  LocalizationConstants.cartEmptyDescriptionKey.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: context.appTextTertiary,
                    height: 1.35,
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

class _CartPageHeader extends StatelessWidget {
  const _CartPageHeader({
    required this.onBack,
    required this.showClearAction,
    required this.onClear,
  });

  final VoidCallback onBack;
  final bool showClearAction;
  final VoidCallback? onClear;

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
          if (showClearAction)
            IconButton(
              tooltip: LocalizationConstants.cartClearKey.tr(),
              onPressed: onClear,
              visualDensity: VisualDensity.compact,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: onClear == null
                    ? context.appTextTertiary
                    : AppColors.error500,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}
