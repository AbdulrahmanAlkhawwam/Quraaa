import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/connectivity/connectivity_ui_helper.dart';
import '../../../../core/connectivity/offline_route_guard.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../bloc/auth_recovery_cubit.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, this.phoneNumber});

  final String? phoneNumber;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final AuthRecoveryCubit _recoveryCubit = sl<AuthRecoveryCubit>();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();


  String get _displayPhoneNumber {
    final String phone = widget.phoneNumber ?? '';
    if (phone.length > 6) {
      return '${phone.substring(0, 3)} ... ${phone.substring(phone.length - 4)}';
    }
    return phone;
  }

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onOtpChanged);
  }
  PinTheme _defaultPinThemeFor(BuildContext context) {
    return PinTheme(
      width: AppDimensions.pinWidth,
      height: AppDimensions.pinHeight,
      textStyle: AppTextStyles.h4.copyWith(
        color: context.isDark ? AppColors.primary300 : AppColors.leafGreen,
      ),
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: Border.all(color: context.appBorder),
      ),
    );
  }

  PinTheme _focusedPinThemeFor(BuildContext context) {
    return _defaultPinThemeFor(context).copyDecorationWith(
      border: Border.all(
        color: context.isDark ? AppColors.primary300 : AppColors.leafGreen,
        width: 2,
      ),
      boxShadow: AppShadows.pinFocused(AppColors.leafGreen),
    );
  }

  PinTheme _submittedPinThemeFor(BuildContext context) {
    return _defaultPinThemeFor(context).copyWith(
      decoration: _defaultPinThemeFor(context).decoration!.copyWith(
        color: context.appSubtleSurface,
      ),
    );
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    _otpFocusNode.dispose();
    _recoveryCubit.close();
    super.dispose();
  }

  void _onOtpChanged() {
    if (_otpController.text.length == 6 && !_recoveryCubit.state.isLoading) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (_recoveryCubit.state.isLoading) return;

    final bool isOnline = await ensureOnline(context);
    if (!isOnline) return;

    await _recoveryCubit.verifyOtp(
      phoneNumber: widget.phoneNumber ?? '',
      code: _otpController.text.trim(),
    );
  }

  Future<void> _onResend() async {
    if (!_recoveryCubit.state.canResendOtp) return;

    final bool isOnline = await ensureOnline(context);
    if (!isOnline) return;

    HapticFeedback.mediumImpact();
    _otpController.clear();
    _otpFocusNode.requestFocus();
    _recoveryCubit.startOtpResendCountdown();
  }

  void _onNumberIsWrong() {
    context.goTo(RouteNames.register);
  }

  void _onRecoveryStateChanged(BuildContext context, AuthRecoveryState state) {
    if (state.status == AuthRecoveryStatus.failure) {
      context.showResolvedErrorSnackBar(state.error);
      return;
    }

    if (state.status == AuthRecoveryStatus.navigate && state.nextRoute != null) {
      context.goTo(state.nextRoute!, extra: state.routeExtra);
    }
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
        child: OfflineRouteGuard(
          child: AppLayout(
            resizeToAvoidBottomInset: true,
            expandContent: true,
            header: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing16,
                vertical: AppSpacing.spacing8,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.back(),
                    icon: Icon(
                      context.isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                      color: AppColors.card,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      LocalizationConstants.authOtpTitleKey.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.card,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing48),
                ],
              ),
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.spacing24,
              AppSpacing.spacing32,
              AppSpacing.spacing24,
              AppSpacing.spacing24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  LocalizationConstants.authOtpDescriptionKey.tr(
                    namedArgs: {'phone': '+$_displayPhoneNumber'},
                  ),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.appTextTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),
                AutofillGroup(
                  child: Center(
                    child: Pinput(
                      controller: _otpController,
                      focusNode: _otpFocusNode,
                      length: 6,
                      keyboardType: TextInputType.number,
                      defaultPinTheme: _defaultPinThemeFor(context),
                      focusedPinTheme: _focusedPinThemeFor(context),
                      submittedPinTheme: _submittedPinThemeFor(context),
                      autofocus: true,
                      showCursor: true,
                      onCompleted: (_) => _verifyOtp(),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: BlocBuilder<AuthRecoveryCubit, AuthRecoveryState>(
                      buildWhen: (
                        AuthRecoveryState previous,
                        AuthRecoveryState current,
                      ) => previous.status != current.status,
                      builder: (
                        BuildContext context,
                        AuthRecoveryState state,
                      ) {
                        return state.isLoading
                            ? const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppColors.leafGreen,
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                BlocBuilder<AuthRecoveryCubit, AuthRecoveryState>(
                  buildWhen: (
                    AuthRecoveryState previous,
                    AuthRecoveryState current,
                  ) => previous.resendCountdown != current.resendCountdown,
                  builder: (BuildContext context, AuthRecoveryState state) {
                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: AppDimensions.onboardingButtonHeight,
                            child: OutlinedButton(
                              onPressed: _onNumberIsWrong,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primary200,
                                ),
                                foregroundColor: AppColors.libraryGreen,
                              ),
                              child: Text(
                                LocalizationConstants
                                    .authOtpNumberIsWrongKey
                                    .tr(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spacing16),
                        Expanded(
                          child: SizedBox(
                            height: AppDimensions.onboardingButtonHeight,
                            child: FilledButton(
                              onPressed: state.canResendOtp ? _onResend : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.leafGreen,
                                foregroundColor: AppColors.card,
                              ),
                              child: Text(
                                state.resendCountdown > 0
                                    ? LocalizationConstants
                                          .authOtpResendCountdownKey
                                          .tr(
                                            namedArgs: {
                                              'count':
                                                  '${state.resendCountdown}',
                                            },
                                          )
                                    : LocalizationConstants.authOtpResendKey
                                          .tr(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
