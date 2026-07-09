import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/connectivity/connectivity_ui_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../bloc/auth_recovery_cubit.dart';
import '../widgets/auth_form_fields.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.phoneNumber});

  final String? phoneNumber;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final AuthRecoveryCubit _recoveryCubit = sl<AuthRecoveryCubit>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeFocusNode.dispose();
    _passwordFocusNode.dispose();
    _recoveryCubit.close();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final bool isOnline = await ensureOnline(context);
    if (!isOnline) return;

    await _recoveryCubit.resetPassword(
      phoneNumber: widget.phoneNumber ?? '',
      code: _codeController.text.trim(),
      newPassword: _passwordController.text,
    );
  }

  void _onRecoveryStateChanged(BuildContext context, AuthRecoveryState state) {
    if (state.status == AuthRecoveryStatus.failure) {
      context.showResolvedErrorSnackBar(state.error);
      return;
    }

    if (state.status != AuthRecoveryStatus.navigate || state.nextRoute == null) {
      return;
    }

    if (state.success == AuthRecoverySuccess.passwordReset) {
      context.showSuccessSnackBar(
        message: Message(
          title: '',
          value: LocalizationConstants.authResetPasswordSuccessKey.tr(),
        ),
      );
    }
    context.goTo(state.nextRoute!, extra: state.routeExtra);
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

  PinTheme _defaultPinTheme(BuildContext context) {
    return PinTheme(
      width: 48,
      height: 56,
      textStyle: AppTextStyles.titleMedium.copyWith(
        color: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
      ),
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: Border.all(color: context.appBorder),
      ),
    );
  }

  PinTheme _focusedPinTheme(BuildContext context) {
    return _defaultPinTheme(context).copyDecorationWith(
      border: Border.all(color: AppColors.leafGreen, width: 2),
    );
  }

  PinTheme _submittedPinTheme(BuildContext context) {
    return _defaultPinTheme(context).copyDecorationWith(
      color: context.appSubtleSurface,
      border: Border.all(color: AppColors.leafGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthRecoveryCubit>.value(
      value: _recoveryCubit,
      child: BlocListener<AuthRecoveryCubit, AuthRecoveryState>(
        listenWhen: (AuthRecoveryState previous, AuthRecoveryState current) =>
            previous.status != current.status ||
            previous.navigationSerial != current.navigationSerial,
        listener: _onRecoveryStateChanged,
        child: AppLayout(
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
                        icon: Icon(
                          context.isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                          color: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          LocalizationConstants.authResetPasswordTitleKey.tr(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h3.copyWith(
                            color: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spacing48),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spacing32),
                  Text(
                    LocalizationConstants
                        .authResetPasswordDescriptionKey
                        .tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.appTextTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing24),
                  AuthLabeledField(
                    label: LocalizationConstants
                        .authResetPasswordCodeLabelKey
                        .tr(),
                    child: AutofillGroup(
                      child: Pinput(
                        controller: _codeController,
                        focusNode: _codeFocusNode,
                        length: 6,
                        keyboardType: TextInputType.number,
                        defaultPinTheme: _defaultPinTheme(context),
                        focusedPinTheme: _focusedPinTheme(context),
                        submittedPinTheme: _submittedPinTheme(context),
                        autofocus: true,
                        showCursor: true,
                        onCompleted: (_) => _passwordFocusNode.requestFocus(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        pinputAutovalidateMode:
                            PinputAutovalidateMode.onSubmit,
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
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
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
                  BlocBuilder<AuthRecoveryCubit, AuthRecoveryState>(
                    builder: (BuildContext context, AuthRecoveryState state) {
                      return SizedBox(
                        height: AppDimensions.onboardingButtonHeight,
                        child: FilledButton(
                          onPressed: state.isLoading ? null : _onSubmit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.leafGreen,
                            foregroundColor: AppColors.card,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.radius32,
                              ),
                            ),
                            textStyle: AppTextStyles.buttonMedium.copyWith(
                              color: AppColors.card,
                            ),
                          ),
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.card,
                                  ),
                                )
                              : Text(
                                  LocalizationConstants
                                      .authResetPasswordButtonKey
                                      .tr(),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
