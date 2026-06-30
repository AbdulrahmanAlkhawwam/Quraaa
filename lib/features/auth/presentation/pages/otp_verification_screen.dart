import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/assets/app_images.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/shared.dart';
import '../../data/datasources/auth_local_datasource.dart';

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
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
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

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: AppColors.leafGreen,
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.leafGreen.withAlpha(40),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.primary50,
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImages.onboardingBackground,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    AppColors.libraryGreen.withAlpha(100),
                    AppColors.libraryGreen.withAlpha(120),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with back button and title
                Padding(
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
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Verification OTP',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h3.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance with back button
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),
                // White content card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.spacing24,
                      AppSpacing.spacing32,
                      AppSpacing.spacing24,
                      AppSpacing.spacing24 + context.bottomPadding,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.radius40),
                        topRight: Radius.circular(AppRadius.radius40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Description
                        Text(
                          'Enter the code sent to your phone number ${_displayPhoneNumber.isNotEmpty ? '+$_displayPhoneNumber' : ''} ... or give us access to see the messages and go check the code',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing32),
                        // Pinput widget with autofill
                        AutofillGroup(
                          child: Center(
                            child: Pinput(
                              controller: _otpController,
                              focusNode: _otpFocusNode,
                              length: 6,
                              keyboardType: TextInputType.number,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              submittedPinTheme: submittedPinTheme,
                              autofocus: true,
                              showCursor: true,
                              onCompleted: (_) => _verifyOtp(),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                              // autofill: const Autofill(
                              //   autofillHints: [AutofillHints.oneTimeCode],
                              // ),
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
                        // Action buttons
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
                                  child: const Text('number is wrong'),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.spacing16),
                            Expanded(
                              child: SizedBox(
                                height: AppDimensions.onboardingButtonHeight,
                                child: FilledButton(
                                  onPressed: _resendCountdown > 0
                                      ? null
                                      : _onResend,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.leafGreen,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    _resendCountdown > 0
                                        ? 'Resend ($_resendCountdown)'
                                        : 'Resend it',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
