import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/connectivity/offline_route_guard.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../widgets/landing_page.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, this.phoneNumber});

  final String? phoneNumber;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthLocalDataSource _authJourney = sl<AuthLocalDataSource>();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  bool _isVerifying = false;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  late final PinTheme _defaultPinTheme;
  late final PinTheme _focusedPinTheme;
  late final PinTheme _submittedPinTheme;

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
    _defaultPinTheme = PinTheme(
      width: AppDimensions.pinWidth,
      height: AppDimensions.pinHeight,
      textStyle: AppTextStyles.h4.copyWith(
        color: AppColors.leafGreen,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: Border.all(
          color: AppColors.primary200,
        ),
      ),
    );
    _focusedPinTheme = _defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: AppColors.leafGreen,
        width: 2,
      ),
      boxShadow: AppShadows.pinFocused(AppColors.leafGreen),
    );
    _submittedPinTheme = _defaultPinTheme.copyWith(
      decoration: _defaultPinTheme.decoration!.copyWith(
        color: AppColors.primary50,
      ),
    );
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    _otpFocusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onOtpChanged() {
    if (_otpController.text.length == 6 && !_isVerifying) {
      _verifyOtp();
    }
    setState(() {});
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;

    setState(() => _isVerifying = true);

    // Simulate verification delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() => _isVerifying = false);
    await _navigateToPermissions(context);
  }

  Future<void> _navigateToPermissions(BuildContext context) async {
    final bool locationSeen = await _authJourney.isLocationPermissionSeen();
    if (!context.mounted) return;
    if (locationSeen) {
      final bool notificationSeen =
          await _authJourney.isNotificationPermissionSeen();
      if (!context.mounted) return;
      if (notificationSeen) {
        context.goTo(RouteNames.home);
      } else {
        context.goTo(RouteNames.notificationPermission);
      }
    } else {
      context.goTo(RouteNames.locationPermission);
    }
  }

  void _onResend() {
    if (_resendCountdown > 0) return;

    HapticFeedback.mediumImpact();
    _otpController.clear();
    setState(() => _resendCountdown = 60);
    _otpFocusNode.requestFocus();

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _resendCountdown--);
      if (_resendCountdown <= 0) {
        timer.cancel();
      }
    });
  }

  void _onNumberIsWrong() {
    context.goTo(RouteNames.register);
  }

  @override
  Widget build(BuildContext context) {
    return OfflineRouteGuard(
      child: LandingPage(
        resizeToAvoidBottomInset: true,
        header: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing16,
            vertical: AppSpacing.spacing8,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.back(),
                icon: const Icon(
                  Icons.arrow_back_ios,
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
        padding: const EdgeInsets.fromLTRB(
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
                color: AppColors.textTertiary,
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
                  defaultPinTheme: _defaultPinTheme,
                  focusedPinTheme: _focusedPinTheme,
                  submittedPinTheme: _submittedPinTheme,
                  autofocus: true,
                  showCursor: true,
                  onCompleted: (_) => _verifyOtp(),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: _isVerifying
                    ? const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.leafGreen,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Row(
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
                        LocalizationConstants.authOtpNumberIsWrongKey.tr(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing16),
                Expanded(
                  child: SizedBox(
                    height: AppDimensions.onboardingButtonHeight,
                    child: FilledButton(
                      onPressed: _resendCountdown > 0 ? null : _onResend,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.leafGreen,
                        foregroundColor: AppColors.card,
                      ),
                      child: Text(
                        _resendCountdown > 0
                            ? LocalizationConstants.authOtpResendCountdownKey
                                .tr(
                                namedArgs: {
                                  'count': '$_resendCountdown',
                                },
                              )
                            : LocalizationConstants.authOtpResendKey.tr(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
