import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/error_message_resolver.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../orders/orders.dart';
import '../../domain/entities/cart_summary.dart';

class CheckoutSelection {
  const CheckoutSelection.checkout({this.shippingLocationId})
      : manageLocations = false,
        resumePendingOrder = false;

  const CheckoutSelection.manageLocations()
      : shippingLocationId = null,
        manageLocations = true,
        resumePendingOrder = false;

  const CheckoutSelection.resumePending()
      : shippingLocationId = null,
        manageLocations = false,
        resumePendingOrder = true;

  final String? shippingLocationId;
  final bool manageLocations;
  final bool resumePendingOrder;
}

class PaymentInfoBottomSheet extends StatefulWidget {
  const PaymentInfoBottomSheet({super.key, required this.summary});

  final CartSummary summary;

  static Future<CheckoutSelection?> show(
    BuildContext context,
    CartSummary summary,
  ) {
    return showModalBottomSheet<CheckoutSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (BuildContext context) => PaymentInfoBottomSheet(
        summary: summary,
      ),
    );
  }

  @override
  State<PaymentInfoBottomSheet> createState() => _PaymentInfoBottomSheetState();
}

class _PaymentInfoBottomSheetState extends State<PaymentInfoBottomSheet> {
  OrderCheckoutContext? _checkoutContext;
  Object? _loadError;
  String? _selectedLocationId;
  bool _loading = true;

  bool get _requiresLocation =>
      _checkoutContext?.requiresShippingLocation == true;

  bool get _isPendingOrderConflict {
    final Object? error = _loadError;
    if (error is! ConflictFailure) return false;
    final String message = error.message.toLowerCase();
    return message.contains('cart is locked') ||
        message.contains('pending order');
  }

  bool get _canContinue =>
      !_loading &&
      (_isPendingOrderConflict ||
          (_loadError == null &&
              (!_requiresLocation || _selectedLocationId != null)));

  String get _loadErrorText => _isPendingOrderConflict
      ? LocalizationConstants.cartPendingOrderLockedKey.tr()
      : ErrorMessageResolver.resolve(_loadError).value;

  @override
  void initState() {
    super.initState();
    _loadCheckoutContext();
  }

  Future<void> _loadCheckoutContext() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final Result<OrderCheckoutContext> result =
        await sl<GetOrderCheckoutContextUseCase>()(const NoParams());
    if (!mounted) return;
    switch (result) {
      case Success<OrderCheckoutContext>(value: final checkoutContext):
        setState(() {
          _checkoutContext = checkoutContext;
          _selectedLocationId = checkoutContext.preferredLocation?.id;
          _loading = false;
        });
      case ResultFailure<OrderCheckoutContext>(
          message: final message,
          cause: final cause,
        ):
        setState(() {
          _loadError = cause ?? message;
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = (context.height * 0.79).clamp(570.0, 760.0);

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
        child: Column(
          children: <Widget>[
            _CheckoutHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.spacing24,
                  AppSpacing.spacing8,
                  AppSpacing.spacing24,
                  AppSpacing.spacing12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _CheckoutTotals(summary: widget.summary),
                    const SizedBox(height: AppSpacing.spacing20),
                    _SectionLabel(
                      text: LocalizationConstants.cartPaymentMethodKey.tr(),
                    ),
                    const SizedBox(height: AppSpacing.spacing10),
                    Row(
                      children: <Widget>[
                        Tooltip(
                          message:
                              LocalizationConstants.cartCashUnavailableKey.tr(),
                          child: _PaymentMethodChip(
                            label: LocalizationConstants.cartCashKey.tr(),
                            selected: false,
                            enabled: false,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spacing10),
                        _PaymentMethodChip(
                          label: LocalizationConstants.cartStripeKey.tr(),
                          selected: true,
                          enabled: true,
                        ),
                      ],
                    ),
                    // const SizedBox(height: AppSpacing.spacing20),
                    // _SectionLabel(
                    //   text: LocalizationConstants.cartPromoKey.tr(),
                    // ),
                    // const SizedBox(height: AppSpacing.spacing8),
                    // TextField(
                    //   enabled: false,
                    //   decoration: _checkoutInputDecoration(
                    //     context,
                    //     LocalizationConstants.cartOfferCodeKey.tr(),
                    //   ).copyWith(
                    //     suffixIcon: Icon(
                    //       Icons.check_circle_outline_rounded,
                    //       color: context.appTextTertiary,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: AppSpacing.spacing20),
                    _SectionLabel(
                      text: LocalizationConstants.cartDeliveryLocationKey.tr(),
                    ),
                    const SizedBox(height: AppSpacing.spacing8),
                    _buildLocationField(context),
                    if (_loadError != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.spacing10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _loadErrorText,
                              style: AppTextStyles.caption.copyWith(
                                color: _isPendingOrderConflict
                                    ? AppColors.primary600
                                    : AppColors.error500,
                              ),
                            ),
                          ),
                          if (!_isPendingOrderConflict)
                            TextButton(
                              onPressed: _loadCheckoutContext,
                              child: Text(
                                LocalizationConstants.commonRetryKey.tr(),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.spacing14),
                    Text(
                      LocalizationConstants.cartSecurePaymentNoteKey.tr(),
                      style: AppTextStyles.caption.copyWith(
                        color: context.appTextTertiary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.spacing24,
                AppSpacing.spacing8,
                AppSpacing.spacing24,
                AppSpacing.spacing18,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _canContinue
                      ? () => Navigator.of(context).pop(
                            _isPendingOrderConflict
                                ? const CheckoutSelection.resumePending()
                                : CheckoutSelection.checkout(
                                    shippingLocationId: _selectedLocationId,
                                  ),
                          )
                      : null,
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
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.card,
                          ),
                        )
                      : Text(
                          (_isPendingOrderConflict
                                  ? LocalizationConstants.cartResumePaymentKey
                                  : LocalizationConstants.cartPaymentNextKey)
                              .tr(),
                          style: AppTextStyles.buttonMedium,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 52,
        child: Center(child: LinearProgressIndicator()),
      );
    }

    final OrderCheckoutContext? checkoutContext = _checkoutContext;
    if (checkoutContext == null) {
      return _CheckoutActionField(
        label: _isPendingOrderConflict
            ? LocalizationConstants.cartResumePaymentKey.tr()
            : _loadErrorText,
        onTap: _isPendingOrderConflict ? null : _loadCheckoutContext,
      );
    }

    if (!checkoutContext.requiresShippingLocation) {
      return _CheckoutActionField(
        label: LocalizationConstants.cartLocationNotRequiredKey.tr(),
      );
    }

    if (checkoutContext.locations.isEmpty) {
      return _CheckoutActionField(
        label: LocalizationConstants.cartAddLocationKey.tr(),
        onTap: () => Navigator.of(
          context,
        ).pop(const CheckoutSelection.manageLocations()),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedLocationId,
      isExpanded: true,
      decoration: _checkoutInputDecoration(
        context,
        LocalizationConstants.cartChooseLocationKey.tr(),
      ),
      dropdownColor: context.appCard,
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedArrowDown01,
        color: AppColors.primary600,
        size: 20,
      ),
      items: checkoutContext.locations
          .map(
            (OrderCheckoutLocation location) => DropdownMenuItem<String>(
              value: location.id,
              child: Text(
                _locationLabel(location),
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.appTextPrimary,
                ),
              ),
            ),
          )
          .toList(growable: false),
      onChanged: (String? value) {
        setState(() => _selectedLocationId = value);
      },
    );
  }

  String _locationLabel(OrderCheckoutLocation location) {
    final String name = location.name?.trim() ?? '';
    final String address = location.address?.trim() ?? '';
    if (name.isNotEmpty && address.isNotEmpty) return '$name â€” $address';
    if (name.isNotEmpty) return name;
    if (address.isNotEmpty) return address;
    return '${location.latitude.toStringAsFixed(4)}, '
        '${location.longitude.toStringAsFixed(4)}';
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.spacing16,
        AppSpacing.spacing18,
        AppSpacing.spacing24,
        AppSpacing.spacing8,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
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
          const SizedBox(width: AppSpacing.spacing6),
          Text(
            LocalizationConstants.cartCheckoutKey.tr(),
            style: AppTextStyles.titleLarge.copyWith(
              color: context.appTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutTotals extends StatelessWidget {
  const _CheckoutTotals({required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: context.appSubtleSurface,
        borderRadius: BorderRadius.circular(AppRadius.radius16),
      ),
      child: Column(
        children: <Widget>[
          _CheckoutTotalRow(
            label: LocalizationConstants.cartSubtotalKey.tr(),
            value: _money(summary.subtotal),
          ),
          const SizedBox(height: AppSpacing.spacing10),
          _CheckoutTotalRow(
            label: LocalizationConstants.cartFatKey.tr(),
            value: '${summary.fatPercent.toStringAsFixed(0)}%',
          ),
          const SizedBox(height: AppSpacing.spacing10),
          _CheckoutTotalRow(
            label: LocalizationConstants.cartDeliveryKey.tr(),
            value: _money(summary.delivery),
          ),
          const SizedBox(height: AppSpacing.spacing10),
          _CheckoutTotalRow(
            label: LocalizationConstants.cartDiscountKey.tr(),
            value: '${summary.discountPercent.toStringAsFixed(0)}%',
          ),
          const SizedBox(height: AppSpacing.spacing12),
          Divider(height: 1, color: context.appBorder),
          const SizedBox(height: AppSpacing.spacing12),
          _CheckoutTotalRow(
            label: LocalizationConstants.cartTotalKey.tr(),
            value: _money(summary.total),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';
}

class _CheckoutTotalRow extends StatelessWidget {
  const _CheckoutTotalRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        (isTotal ? AppTextStyles.titleMedium : AppTextStyles.bodySmall)
            .copyWith(
      color: isTotal ? context.appTextPrimary : context.appTextSecondary,
      fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
    );
    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(color: context.appTextPrimary),
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  const _PaymentMethodChip({
    required this.label,
    required this.selected,
    required this.enabled,
  });

  final String label;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary500 : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.radius24),
        border: Border.all(
          color: selected ? AppColors.primary500 : context.appBorder,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: selected
              ? AppColors.card
              : enabled
                  ? context.appTextPrimary
                  : context.appTextTertiary,
        ),
      ),
    );
  }
}

class _CheckoutActionField extends StatelessWidget {
  const _CheckoutActionField({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing14),
          decoration: BoxDecoration(
            border: Border.all(color: context.appBorder),
            borderRadius: BorderRadius.circular(AppRadius.radius8),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: onTap == null
                        ? context.appTextSecondary
                        : AppColors.primary600,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(Icons.add_location_alt_outlined,
                    color: AppColors.primary600),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _checkoutInputDecoration(
  BuildContext context,
  String hintText,
) {
  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.radius8),
    borderSide: BorderSide(color: context.appBorder),
  );
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTextStyles.bodySmall.copyWith(color: context.appTextTertiary),
    filled: true,
    fillColor: context.appCard,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.spacing14,
      vertical: AppSpacing.spacing14,
    ),
    enabledBorder: border,
    disabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.primary600, width: 1.4),
    ),
  );
}
