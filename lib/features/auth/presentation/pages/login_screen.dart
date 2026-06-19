import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../../../core/assets/app_images.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../onboarding/domain/repositories/onboarding_repository.dart';
import '../../data/datasources/auth_local_datasource.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthLocalDataSource _authJourney = sl<AuthLocalDataSource>();
  final OnboardingRepository _onboardingRepository =
      sl<OnboardingRepository>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  PhoneNumber? _phoneNumber;
  bool _isPhoneValid = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    unawaited(_authJourney.markLoginSeen());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _goBack() async {
    final AuthJourneyStage? previousStage =
        await _authJourney.getPreviousStage();
    if (_shouldResumeOnboarding(previousStage)) {
      await _onboardingRepository.resetCompletion();
    }
    await _authJourney.saveJourneyStage(
      previousStage ?? AuthJourneyStage.auth,
      previousStage: AuthJourneyStage.login,
    );
    if (!mounted) return;
    context.goTo(_routeForStage(previousStage));
  }

  Future<void> _continueAsUser() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      unawaited(
        sl<UserContextProvider>().recordAction('Auth submit blocked'),
      );
      return;
    }

    final PhoneNumber phoneNumber = _phoneNumber ?? PhoneNumber();
    final String normalizedPhone =
        phoneNumber.phoneNumber?.trim() ?? _phoneController.text.trim();

    unawaited(
      sl<UserContextProvider>().recordAction('Auth submit with data'),
    );

    setState(() => _isLoading = true);
    try {
      await _authJourney.markAuthenticatedSession();
      await sl<UserContextProvider>().setUser(
        id: normalizedPhone,
        name: normalizedPhone,
        phone: normalizedPhone,
        subscriptionStatus: 'active',
      );
      if (!mounted) return;
      context.goTo(RouteNames.home);
    } catch (error) {
      if (!mounted) return;
      context.showErrorSnackBar(
        message: Message(
          title: LocalizationConstants.authLoginTitleKey.tr(),
          value: error.toString(),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    await _authJourney.markGuestSession();
    await sl<UserContextProvider>().clearUser();
    if (!mounted) return;
    context.goTo(RouteNames.home);
  }

  String _routeForStage(AuthJourneyStage? stage) {
    return switch (stage) {
      AuthJourneyStage.auth => RouteNames.auth,
      AuthJourneyStage.login => RouteNames.login,
      AuthJourneyStage.register => RouteNames.register,
      AuthJourneyStage.onboarding => RouteNames.onboarding,
      AuthJourneyStage.onboardingAge => RouteNames.onboardingAge,
      AuthJourneyStage.onboardingInterests => RouteNames.onboardingInterests,
      AuthJourneyStage.home => RouteNames.home,
      null => RouteNames.auth,
    };
  }

  bool _shouldResumeOnboarding(AuthJourneyStage? stage) {
    return stage == AuthJourneyStage.onboarding ||
        stage == AuthJourneyStage.onboardingAge ||
        stage == AuthJourneyStage.onboardingInterests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Stack(
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
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: _RoundIconButton(
                            icon: HugeIcons.strokeRoundedArrowLeft01,
                            onPressed: () {
                              unawaited(
                                sl<UserContextProvider>().recordAction(
                                  'Auth back button',
                                ),
                              );
                              _goBack();
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing20),
                        Text(
                          LocalizationConstants.authLoginTitleKey.tr(),
                          textAlign: TextAlign.start,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.libraryGreen,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing32),
                        _LabeledField(
                          label: LocalizationConstants.authPhoneLabelKey.tr(),
                          child: PhoneNumberInput(
                            controller: _phoneController,
                            initialValue: PhoneNumber(isoCode: 'SY'),
                            countries: const <String>[
                              // 'AE',
                              // 'BH',
                              // 'EG',
                              // 'IQ',
                              // 'JO',
                              // 'KW',
                              // 'LB',
                              // 'OM',
                              // 'QA',
                              // 'SA',
                              'SY',
                            ],
                            onInputChanged: (PhoneNumber value) {
                              _phoneNumber = value;
                            },
                            onInputValidated: (bool value) {
                              if (_isPhoneValid != value) {
                                setState(() {
                                  _isPhoneValid = value;
                                });
                              }
                            },
                            validator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return LocalizationConstants.authPhoneHintKey
                                    .tr();
                              }
                              if (!_isPhoneValid ||
                                  _phoneNumber?.isoCode == null) {
                                return 'Please enter a valid phone number and country';
                              }
                              return null;
                            },
                            autoValidateMode:
                                AutovalidateMode.onUserInteraction,
                            onFieldSubmitted: _continueAsUser,
                            hintText: LocalizationConstants.authPhoneHintKey
                                .tr(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing16),
                        _LabeledField(
                          label: LocalizationConstants.authPasswordLabelKey
                              .tr(),
                          child: _AuthTextField(
                            controller: _passwordController,
                            hintText: LocalizationConstants.authPasswordHintKey
                                .tr(),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
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
                            onSubmitted: (_) => _continueAsUser(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing32),
                        SizedBox(
                          height: AppDimensions.onboardingButtonHeight,
                          child: FilledButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    unawaited(
                                      sl<UserContextProvider>().recordAction(
                                        'Auth primary button',
                                      ),
                                    );
                                    _continueAsUser();
                                  },
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    LocalizationConstants.authNextKey.tr()),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing24),
                        SizedBox(
                          height: AppDimensions.onboardingButtonHeight,
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    unawaited(
                                      sl<UserContextProvider>().recordAction(
                                        'Auth secondary button',
                                      ),
                                    );
                                    _continueAsGuest();
                                  },
                            child: Text(
                              LocalizationConstants.authContinueAsGuestKey
                                  .tr(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.libraryGreen,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing12),
        child,
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final List<List<dynamic>> icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.spacing48,
      height: AppSpacing.spacing48,
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius16),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: HugeIcon(
            icon: icon,
            color: AppColors.textPrimary,
            size: 18,
          ),
          splashRadius: 22,
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.textInputAction,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.onboardingInputHeight,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        textCapitalization: textCapitalization,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimary,
        ),
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
