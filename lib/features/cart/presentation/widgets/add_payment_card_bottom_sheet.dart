import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import 'payment_card_mark.dart';

class AddPaymentCardBottomSheet extends StatefulWidget {
  const AddPaymentCardBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.34),
      builder: (BuildContext context) => const AddPaymentCardBottomSheet(),
    );
  }

  @override
  State<AddPaymentCardBottomSheet> createState() =>
      _AddPaymentCardBottomSheetState();
}

class _AddPaymentCardBottomSheetState extends State<AddPaymentCardBottomSheet> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  String? _country;

  bool get _canSubmit =>
      _cardNumberController.text.trim().length >= 12 &&
      _expiryController.text.trim().length >= 4 &&
      _cvcController.text.trim().length >= 3 &&
      _zipController.text.trim().isNotEmpty &&
      _country != null;

  @override
  void initState() {
    super.initState();
    for (final TextEditingController controller in <TextEditingController>[
      _cardNumberController,
      _expiryController,
      _cvcController,
      _zipController,
    ]) {
      controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = context.height * 0.82;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: context.appCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.radius28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.spacing24,
              AppSpacing.spacing20,
              AppSpacing.spacing24,
              AppSpacing.spacing20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SheetHeader(onBack: () => Navigator.of(context).pop()),
                const SizedBox(height: AppSpacing.spacing24),
                Text(
                  LocalizationConstants.cartAddCardInfoKey.tr(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.appTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                _PaymentTextField(
                  controller: _cardNumberController,
                  hintText: LocalizationConstants.cartAddCardNumberKey.tr(),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(19),
                  ],
                  suffix: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      MastercardMark(),
                      SizedBox(width: AppSpacing.spacing10),
                      Text(
                        'VISA',
                        style: TextStyle(
                          color: Color(0xFF1A1F71),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _LabeledPaymentField(
                        label: LocalizationConstants.cartAddCardExpiryKey.tr(),
                        child: _PaymentTextField(
                          controller: _expiryController,
                          hintText: 'MM/YY',
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacing10),
                    Expanded(
                      child: _LabeledPaymentField(
                        label: LocalizationConstants.cartAddCardCvcKey.tr(),
                        child: _PaymentTextField(
                          controller: _cvcController,
                          hintText: '***',
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacing18),
                Text(
                  LocalizationConstants.cartAddCardCountryRegionKey.tr(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.appTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                DropdownButtonFormField<String>(
                  initialValue: _country,
                  isExpanded: true,
                  decoration: _fieldDecoration(
                    context,
                    LocalizationConstants.cartAddCardCountryKey.tr(),
                  ),
                  dropdownColor: context.appCard,
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowDown01,
                    color: AppColors.primary600,
                    size: 20,
                  ),
                  items: <String>[
                    LocalizationConstants.cartAddCardCountrySyriaKey.tr(),
                    LocalizationConstants.cartAddCardCountryUaeKey.tr(),
                    LocalizationConstants.cartAddCardCountryUsaKey.tr(),
                  ]
                      .map(
                        (String country) => DropdownMenuItem<String>(
                          value: country,
                          child: Text(
                            country,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: context.appTextPrimary,
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (String? value) =>
                      setState(() => _country = value),
                ),
                const SizedBox(height: AppSpacing.spacing12),
                _LabeledPaymentField(
                  label: LocalizationConstants.cartAddCardZipCodeKey.tr(),
                  child: _PaymentTextField(
                    controller: _zipController,
                    hintText: LocalizationConstants.cartAddCardZipHintKey.tr(),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed:
                        _canSubmit ? () => Navigator.of(context).pop() : null,
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
                      LocalizationConstants.cartAddCardSubmitKey.tr(),
                      style: AppTextStyles.buttonSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: onBack,
          visualDensity: VisualDensity.compact,
          icon: HugeIcon(
            icon: context.isRTL
                ? HugeIcons.strokeRoundedArrowRight01
                : HugeIcons.strokeRoundedArrowLeft01,
            color:
                context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
            size: 23,
          ),
        ),
        const SizedBox(width: AppSpacing.spacing8),
        Expanded(
          child: Text(
            LocalizationConstants.cartAddCardTitleKey.tr(),
            style: AppTextStyles.titleLarge.copyWith(
              color: context.appTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledPaymentField extends StatelessWidget {
  const _LabeledPaymentField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: context.appTextSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing6),
        child,
      ],
    );
  }
}

class _PaymentTextField extends StatelessWidget {
  const _PaymentTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        style: AppTextStyles.bodySmall.copyWith(color: context.appTextPrimary),
        decoration: _fieldDecoration(context, hintText).copyWith(
          suffixIcon: suffix == null
              ? null
              : Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: AppSpacing.spacing14,
                  ),
                  child: suffix,
                ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(BuildContext context, String hintText) {
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
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.primary600, width: 1.4),
    ),
  );
}
