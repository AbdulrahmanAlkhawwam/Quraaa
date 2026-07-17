import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/cart_item.dart';
import '../bloc/cart_bloc.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../home/presentation/widgets/home_bottom_nav.dart';
import 'cart_coupon_card.dart';
import 'cart_item_tile.dart';
import 'cart_totals_card.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});
  void _onNavItemTapped(BuildContext context, int index) {
    final String route = switch (index) {
      0 => RouteNames.home,
      1 => RouteNames.libraries,
      2 => RouteNames.userBooks,
      3 => RouteNames.audioBooks,
      4 => RouteNames.cart,
      _ => RouteNames.home,
    };

    if (route != RouteNames.cart) {
      context.goTo(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color background = context.appBackground;
    final Brightness overlayBrightness =
        context.isDark ? Brightness.light : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: background,
        statusBarIconBrightness: overlayBrightness,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: overlayBrightness,
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1),
        ),
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: background,
          appBar: const HomeAppBar(),
          body: Stack(
            children: <Widget>[
              BlocBuilder<CartBloc, CartState>(
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
                      final double scale = constraints.compactFeatureScale;
                      final double horizontal =
                          (constraints.maxWidth * 0.045).clamp(18.0, 22.0);
                      final double topPadding =
                          (constraints.maxHeight * 0.032).clamp(18.0, 28.0);

                      return SafeArea(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            horizontal,
                            topPadding,
                            horizontal,
                            0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: state.summary.items.length,
                                  itemBuilder: (
                                    BuildContext context,
                                    int index,
                                  ) {
                                    final CartItem item =
                                        state.summary.items[index];
                                    return CartItemTile(
                                      item: item,
                                      showDivider: index !=
                                          state.summary.items.length - 1,
                                      onIncrease: () =>
                                          context.read<CartBloc>().add(
                                                CartQuantityIncreased(item),
                                              ),
                                      onDecrease: () =>
                                          context.read<CartBloc>().add(
                                                CartQuantityDecreased(item),
                                              ),
                                      onRemove: () =>
                                          context.read<CartBloc>().add(
                                                CartItemRemoved(item.id),
                                              ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 10 * scale),
                              if (state.summary.items.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 20 * scale,
                                    ),
                                    child: Text(
                                      LocalizationConstants.cartEmptyKey.tr(),
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: context.appTextSecondary,
                                        fontSize: 17 * scale,
                                      ),
                                    ),
                                  ),
                                ),
                              CartCouponCard(
                                code: state.summary.couponCode,
                                applied: state.summary.couponApplied,
                                onApply: () => context.read<CartBloc>().add(
                                      CartCouponSubmitted(
                                        state.summary.couponCode,
                                      ),
                                    ),
                              ),
                              SizedBox(height: 14 * scale),
                              CartTotalsCard(summary: state.summary),
                              SizedBox(height: 120 * scale),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 0,
                child: HomeBottomNav(
                  currentIndex: 4,
                  onTap: (int index) => _onNavItemTapped(context, index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
