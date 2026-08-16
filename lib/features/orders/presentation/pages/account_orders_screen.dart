import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../shared/shared.dart';
import '../../../home/presentation/widgets/home_order_status_card.dart';
import '../../domain/entities/account_order.dart';
import '../../domain/entities/order_checkout_context.dart';
import '../cubit/account_orders_cubit.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AccountOrdersView(mode: AccountOrdersMode.purchases);
  }
}

class MySellsScreen extends StatelessWidget {
  const MySellsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AccountOrdersView(mode: AccountOrdersMode.sales);
  }
}

class _AccountOrdersView extends StatelessWidget {
  const _AccountOrdersView({required this.mode});

  final AccountOrdersMode mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            context.isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: context.appTextPrimary,
            size: 20,
          ),
        ),
        titleSpacing: 0,
        title: Text(
          (mode == AccountOrdersMode.sales
                  ? 'orders.my_sells'
                  : 'orders.my_orders')
              .tr(),
          style: AppTextStyles.h3.copyWith(color: context.appTextPrimary),
        ),
      ),
      body: BlocBuilder<AccountOrdersCubit, AccountOrdersState>(
        builder: (BuildContext context, AccountOrdersState state) {
          return RefreshIndicator(
            onRefresh: () => context.read<AccountOrdersCubit>().load(
                  salesFilter: state.salesFilter,
                ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                if (mode == AccountOrdersMode.sales)
                  SliverToBoxAdapter(child: _SalesFilters(state: state)),
                if (state.loading && state.orders.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.error != null && state.orders.isEmpty)
                  SliverFillRemaining(
                    child: _MessageState(
                      icon: Icons.cloud_off_outlined,
                      message: state.error!,
                      onRetry: context.read<AccountOrdersCubit>().load,
                    ),
                  )
                else if (state.orders.isEmpty)
                  SliverFillRemaining(
                    child: _MessageState(
                      icon: Icons.receipt_long_outlined,
                      message: 'orders.empty'.tr(),
                      onRetry: context.read<AccountOrdersCubit>().load,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
                    sliver: SliverList.separated(
                      itemCount: state.orders.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.spacing16),
                      itemBuilder: (BuildContext context, int index) {
                        final AccountOrder order = state.orders[index];
                        return _OrderGroup(
                          order: order,
                          showProgress: mode == AccountOrdersMode.purchases &&
                              index == 0 &&
                              order.stage != AccountOrderStage.cancelled,
                          isSale: mode == AccountOrdersMode.sales,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SalesFilters extends StatelessWidget {
  const _SalesFilters({required this.state});

  final AccountOrdersState state;

  static const List<(String, int)> _filters = <(String, int)>[
    ('orders.completed', 2),
    ('orders.pending', 0),
    ('orders.processing', 1),
    ('orders.rejected', 3),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      child: Row(
        children: _filters.map(((String, int) filter) {
          final bool selected = state.salesFilter == filter.$2;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: ChoiceChip(
              label: Text(filter.$1.tr()),
              selected: selected,
              showCheckmark: false,
              selectedColor: AppColors.primary600,
              backgroundColor: context.appCard,
              side: BorderSide(color: AppColors.primary300),
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.primary600,
              ),
              onSelected: (_) => context
                  .read<AccountOrdersCubit>()
                  .load(salesFilter: filter.$2),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _OrderGroup extends StatelessWidget {
  const _OrderGroup({
    required this.order,
    required this.showProgress,
    required this.isSale,
  });

  final AccountOrder order;
  final bool showProgress;
  final bool isSale;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    if (showProgress) {
      children.add(
        HomeOrderStatusCard(
          orderNumber: order.orderNumber,
          status: _homeStatus(order.stage),
        ),
      );
      children.add(const SizedBox(height: AppSpacing.spacing16));
    }
    if (order.items.isEmpty) {
      children.add(_OrderSummaryCard(order: order));
    } else {
      for (int index = 0; index < order.items.length; index++) {
        children.add(
          _OrderBookCard(
            order: order,
            item: order.items[index],
            isSale: isSale,
          ),
        );
        if (index != order.items.length - 1) {
          children.add(const SizedBox(height: AppSpacing.spacing12));
        }
      }
    }
    if (!isSale && order.stage == AccountOrderStage.pending) {
      children.add(const SizedBox(height: AppSpacing.spacing12));
      children.add(_ChangeShippingButton(order: order));
      children.add(const SizedBox(height: AppSpacing.spacing8));
      children.add(_CancelOrderButton(order: order));
    }
    return Column(children: children);
  }

  HomeOrderStatus _homeStatus(AccountOrderStage status) => switch (status) {
        AccountOrderStage.pending => HomeOrderStatus.pending,
        AccountOrderStage.processing => HomeOrderStatus.processing,
        AccountOrderStage.onDelivery => HomeOrderStatus.onDelivery,
        AccountOrderStage.onDoor ||
        AccountOrderStage.cancelled =>
          HomeOrderStatus.onDoor,
      };
}

class _ChangeShippingButton extends StatelessWidget {
  const _ChangeShippingButton({required this.order});

  final AccountOrder order;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _change(context),
        icon: const Icon(Icons.location_on_outlined),
        label: Text('orders.change_shipping_location'.tr()),
      ),
    );
  }

  Future<void> _change(BuildContext context) async {
    final AccountOrdersCubit cubit = context.read<AccountOrdersCubit>();
    final OrderCheckoutContext? checkout = await cubit.getShippingContext();
    if (!context.mounted) return;
    if (checkout == null || checkout.locations.isEmpty) {
      final String message = cubit.state.error ?? 'orders.no_locations'.tr();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    final OrderCheckoutLocation? selected =
        await showDialog<OrderCheckoutLocation>(
      context: context,
      builder: (BuildContext dialogContext) => SimpleDialog(
        title: Text('orders.choose_shipping_location'.tr()),
        children: checkout.locations
            .map(
              (OrderCheckoutLocation location) => SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, location),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(location.name?.trim().isNotEmpty == true
                      ? location.name!
                      : location.address ?? ''),
                  subtitle: location.name?.trim().isNotEmpty == true &&
                          location.address?.trim().isNotEmpty == true
                      ? Text(location.address!)
                      : null,
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
    if (selected == null || !context.mounted) return;
    final bool success = await cubit.updateShippingLocation(order, selected);
    if (!context.mounted) return;
    final String message = success
        ? 'orders.shipping_location_updated'.tr()
        : cubit.state.error ?? 'orders.shipping_location_update_failed'.tr();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _CancelOrderButton extends StatelessWidget {
  const _CancelOrderButton({required this.order});

  final AccountOrder order;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error500),
        onPressed: () => _confirm(context),
        child: Text('orders.cancel_order'.tr()),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final String? reason = await showDialog<String>(
      context: context,
      builder: (_) => const _CancelOrderDialog(),
    );
    if (reason == null || !context.mounted) return;
    final bool success = await context
        .read<AccountOrdersCubit>()
        .cancel(order, reason: reason.isEmpty ? null : reason);
    if (!context.mounted || success) return;
    final String message = context.read<AccountOrdersCubit>().state.error ??
        'orders.cancel_failed'.tr();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _CancelOrderDialog extends StatefulWidget {
  const _CancelOrderDialog();

  @override
  State<_CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<_CancelOrderDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('orders.cancel_order'.tr()),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'orders.cancel_reason_optional'.tr(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => context.pop(),
          child: Text('common.cancel'.tr()),
        ),
        FilledButton(
          onPressed: () => context.pop(_controller.text.trim()),
          child: Text('orders.confirm_cancel'.tr()),
        ),
      ],
    );
  }
}

class _OrderBookCard extends StatelessWidget {
  const _OrderBookCard({
    required this.order,
    required this.item,
    required this.isSale,
  });

  final AccountOrder order;
  final AccountOrderItem item;
  final bool isSale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.isDark
          ? AppColors.settingsCardBackgroundDark
          : AppColors.settingsCardBackground,
      borderRadius: BorderRadius.circular(AppRadius.radius16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.radius16),
        onTap: item.listingId.isEmpty
            ? null
            : () => context.push(RouteNames.bookDetailsPath(item.listingId)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _CoverImage(url: item.coverImageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _StatusBadge(status: item.fulfillmentStatus),
                    const SizedBox(height: 4),
                    Text(
                      item.title.isEmpty ? 'orders.book'.tr() : item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: context.appTextPrimary,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _MetaLine(
                      label: 'orders.author'.tr(),
                      value: item.author,
                    ),
                    _MetaLine(
                      label: 'orders.type'.tr(),
                      value: item.format,
                    ),
                    _MetaLine(
                      label: 'orders.date'.tr(),
                      value: _formatDate(order.creationTime),
                    ),
                    _MetaLine(
                      label: 'orders.book_status'.tr(),
                      value: item.condition,
                    ),
                    if (isSale && order.isSaleHistory) ...<Widget>[
                      _MetaLine(
                        label: 'orders.quantity'.tr(),
                        value: item.quantity.toString(),
                      ),
                      _MetaLine(
                        label: 'orders.unit_price'.tr(),
                        value: _money(item.unitPrice, order.currency),
                      ),
                      _MetaLine(
                        label: 'orders.total_earned'.tr(),
                        value: _money(order.totalAmount, order.currency),
                      ),
                    ] else if (isSale)
                      _MetaLine(
                        label: 'orders.price'.tr(),
                        value: _money(item.unitPrice, order.currency),
                      ),
                    if (isSale && item.fulfillmentStatus < 2) ...<Widget>[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 34,
                        child: FilledButton(
                          onPressed: () => context
                              .read<AccountOrdersCubit>()
                              .advance(order, item),
                          child: Text(
                            (item.fulfillmentStatus == 0
                                    ? 'orders.start_processing'
                                    : 'orders.mark_fulfilled')
                                .tr(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    return '${value.day.toString().padLeft(2, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-${value.year}';
  }

  String _money(double value, String currency) {
    final String normalizedCurrency = currency.trim().toUpperCase();
    return normalizedCurrency.isEmpty
        ? value.toStringAsFixed(2)
        : '${value.toStringAsFixed(2)} $normalizedCurrency';
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final AccountOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appSubtleSurface,
        borderRadius: BorderRadius.circular(AppRadius.radius16),
      ),
      child: Text(
        '${'orders.order'.tr()} #${order.orderNumber}\n'
        '${order.totalAmount.toStringAsFixed(2)} ${order.currency}',
        style: AppTextStyles.bodyLarge.copyWith(color: context.appTextPrimary),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 112,
        height: 144,
        child: url.isEmpty
            ? ColoredBox(
                color: AppColors.primary100,
                child: const Icon(Icons.menu_book_outlined),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: AppColors.primary100,
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final int status;

  @override
  Widget build(BuildContext context) {
    final String key = switch (status) {
      0 => 'orders.pending',
      1 => 'orders.processing',
      2 => 'orders.completed',
      _ => 'orders.rejected',
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status == 3 ? AppColors.error500 : AppColors.primary400,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          key.tr(),
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        '$label : $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary600),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 52, color: AppColors.primary500),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: onRetry, child: Text('common.retry'.tr())),
          ],
        ),
      ),
    );
  }
}
