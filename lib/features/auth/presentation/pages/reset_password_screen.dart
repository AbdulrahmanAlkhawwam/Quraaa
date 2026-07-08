import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pinput/pinput.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/connectivity/connectivity_ui_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/use_cases/reset_password_use_case.dart';
import '../widgets/auth_form_fields.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.phoneNumber});

  final String? phoneNumber;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ResetPasswordUseCase _resetPasswordUseCase = sl<ResetPasswordUseCase>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final bool isOnline = await ensureOnline(context);
    if (!isOnline) return;

    final String phone = widget.phoneNumber ?? '';
    final String code = _codeController.text.trim();
    final String password = _passwordController.text;

    setState(() => _isSubmitting = true);

    final result = await _resetPasswordUseCase(
      ResetPasswordParams(
        phoneNumber: phone,
        code: code,
        newPassword: password,
      ),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    await result.fold(
      (failure) async {
        if (!mounted) return;
        context.showResolvedErrorSnackBar(failure);
      },
      (_) async {
        if (!mounted) return;
        context.showSuccessSnackBar(
          message: Message(
            title: '',
            value: LocalizationConstants.authResetPasswordSuccessKey.tr(),
          ),
        );
        context.goTo(RouteNames.login);
      },
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return LocalizationConstants.authPasswordRequiredErrorKey.tr();
    }
    if (value.length < 6) {
      return LocalizationConstants.authPasswordMinLengthErrorKey.tr();
    }
    if (!value.contains(RegExp('[0-9]'))) {
      return LocalizationConstants.authPasswordDigitErrorKey.tr();
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return LocalizationConstants.authPasswordRequiredErrorKey.tr();
    }
    if (value != _passwordController.text) {
      return LocalizationConstants.authResetPasswordPasswordMismatchKey.tr();
    }
    return null;
  }

  PinTheme get _defaultPinTheme {
    return PinTheme(
      width: 48,
      height: 56,
      textStyle: AppTextStyles.titleMedium.copyWith(
        color: AppColors.libraryGreen,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: Border.all(color: AppColors.primary200),
      ),
    );
  }

  PinTheme get _focusedPinTheme {
    return _defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.leafGreen, width: 2),
    );
  }

  PinTheme get _submittedPinTheme {
    return _defaultPinTheme.copyDecorationWith(
      color: AppColors.primary100,
      border: Border.all(color: AppColors.leafGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      expandContent: true,
      resizeToAvoidBottomInset: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.back(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.libraryGreen,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      LocalizationConstants.authResetPasswordTitleKey.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.libraryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing48),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing32),
              Text(
                LocalizationConstants.authResetPasswordDescriptionKey.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing24),
              AuthLabeledField(
                label: LocalizationConstants.authResetPasswordCodeLabelKey.tr(),
                child: AutofillGroup(
                  child: Pinput(
                    controller: _codeController,
                    focusNode: _codeFocusNode,
                    length: 6,
                    keyboardType: TextInputType.number,
                    defaultPinTheme: _defaultPinTheme,
                    focusedPinTheme: _focusedPinTheme,
                    submittedPinTheme: _submittedPinTheme,
                    autofocus: true,
                    showCursor: true,
                    onCompleted: (_) => _passwordFocusNode.requestFocus(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spacing24),
              AuthLabeledField(
                label: LocalizationConstants
                    .authResetPasswordNewPasswordLabelKey
                    .tr(),
                child: AuthTextField(
                  controller: _passwordController,
                  hintText: LocalizationConstants
                      .authResetPasswordNewPasswordHintKey
                      .tr(),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: HugeIcon(
                      icon: _obscurePassword
                          ? HugeIcons.strokeRoundedViewOff
                          : HugeIcons.strokeRoundedView,
                      color: AppColors.primary300,
                      size: 20,
                    ),
                  ),
                  validator: _validatePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing16),
              AuthLabeledField(
                label: LocalizationConstants
                    .authResetPasswordConfirmPasswordLabelKey
                    .tr(),
                child: AuthTextField(
                  controller: _confirmPasswordController,
                  hintText: LocalizationConstants
                      .authResetPasswordConfirmPasswordHintKey
                      .tr(),
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: HugeIcon(
                      icon: _obscureConfirmPassword
                          ? HugeIcons.strokeRoundedViewOff
                          : HugeIcons.strokeRoundedView,
                      color: AppColors.primary300,
                      size: 20,
                    ),
                  ),
                  validator: _validateConfirmPassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onSubmitted: (_) => _onSubmit(),
                ),
              ),
              const SizedBox(height: AppSpacing.spacing32),
              SizedBox(
                height: AppDimensions.onboardingButtonHeight,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.leafGreen,
                    foregroundColor: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.radius32),
                    ),
                    textStyle: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.card,
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.card,
                          ),
                        )
                      : Text(
                          LocalizationConstants.authResetPasswordButtonKey.tr(),
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
