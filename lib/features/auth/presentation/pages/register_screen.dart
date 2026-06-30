import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../../../core/assets/app_images.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/widgets/phone_number_input.dart';
import '../../../onboarding/domain/entities/gender_selection.dart';
import '../../../onboarding/domain/entities/onboarding_draft.dart';
import '../../../onboarding/domain/repositories/onboarding_repository.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView({super.key});

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final AuthLocalDataSource _authJourney = sl<AuthLocalDataSource>();
  final OnboardingRepository _onboardingRepository = sl<OnboardingRepository>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  PhoneNumber? _phoneNumber;
  bool _isPhoneValid = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    unawaited(_authJourney.markRegisterSeen());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continueAsUser() async {
    await _authJourney.markAuthenticatedSession();
    await sl<UserContextProvider>().setUser(
      id: 'registered-user',
      name: 'Registered user',
      subscriptionStatus: 'active',
    );
    if (!mounted) return;
    await _navigatePostRegister(context);
  }

  Future<void> _continueAsGuest() async {
    await _authJourney.markGuestSession();
    await sl<UserContextProvider>().clearUser();
    if (!mounted) return;
    await _navigatePostRegister(context);
  }

  Future<void> _navigatePostRegister(BuildContext context) async {
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

  Future<void> _submitRegistration() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      unawaited(sl<UserContextProvider>().recordAction('Auth submit blocked'));
      return;
    }

    unawaited(sl<UserContextProvider>().recordAction('Auth submit with data'));

    final OnboardingDraft onboardingDraft = await _onboardingRepository
        .loadState();
    final GenderSelection? selectedGender = onboardingDraft.selectedGender;
    final int? birthYear = onboardingDraft.birthYear;
    final int? birthMonth = onboardingDraft.birthMonth;
    final int? birthDay = onboardingDraft.birthDay;
    final String? categoryId = onboardingDraft.selectedCategoryId;

    if (selectedGender == null ||
        birthYear == null ||
        birthMonth == null ||
        birthDay == null) {
      if (!mounted) return;
      context.showErrorSnackBar(
        message: const Message(
          title: 'Registration incomplete',
          value: 'Please finish onboarding before registering.',
        ),
      );
      return;
    }

    if (categoryId == null) {
      if (!mounted) return;
      context.showErrorSnackBar(
        message: const Message(
          title: 'Registration incomplete',
          value: 'Please select an interest category before registering.',
        ),
      );
      return;
    }

    final String formattedDateOfBirth =
        '${birthYear.toString().padLeft(4, '0')}-${birthMonth.toString().padLeft(2, '0')}-${birthDay.toString().padLeft(2, '0')}';

    final PhoneNumber phoneNumber = _phoneNumber ?? PhoneNumber();
    final String normalizedPhone =
        phoneNumber.phoneNumber?.trim() ?? _phoneController.text.trim();

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        phoneNumber: normalizedPhone,
        password: _passwordController.text,
        gender: _genderToApiValue(selectedGender),
        dateOfBirth: formattedDateOfBirth,
        categoryId: categoryId,
      ),
    );
  }

  int _genderToApiValue(GenderSelection gender) {
    return switch (gender) {
      GenderSelection.boy => 0,
      GenderSelection.girl => 1,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        switch (state) {
          case AuthSuccess():
            unawaited(_navigatePostRegister(context));
          case AuthError(:final message):
            context.showErrorSnackBar(
              message: Message(title: 'Registration failed', value: message),
            );
          case _:
            break;
        }
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
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
                            Text(
                              LocalizationConstants.authRegisterTitleKey.tr(),
                              textAlign: TextAlign.start,
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.libraryGreen,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spacing32),
                            _LabeledField(
                              label: LocalizationConstants.authPhoneLabelKey
                                  .tr(),
                              child: Material(
                                type: MaterialType.transparency,
                                child: PhoneNumberInput(
                                  controller: _phoneController,
                                  initialValue: PhoneNumber(isoCode: 'SY'),
                                  countries: const <String>[
                                    'AE',
                                    'BH',
                                    'EG',
                                    'IQ',
                                    'JO',
                                    'KW',
                                    'LB',
                                    'OM',
                                    'QA',
                                    'SA',
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
                                      return LocalizationConstants
                                          .authPhoneHintKey
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
                                  onFieldSubmitted: _submitRegistration,
                                  hintText: LocalizationConstants
                                      .authPhoneHintKey
                                      .tr(),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spacing16),
                            _LabeledField(
                              label: LocalizationConstants.authPasswordLabelKey
                                  .tr(),
                              child: _AuthTextField(
                                controller: _passwordController,
                                hintText: LocalizationConstants
                                    .authPasswordHintKey
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return LocalizationConstants
                                        .authPasswordHintKey
                                        .tr();
                                  }
                                  return null;
                                },
                                onSubmitted: (_) => _submitRegistration(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spacing32),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (BuildContext context, AuthState state) {
                                final bool isLoading = state is AuthLoading;
                                return SizedBox(
                                  height: AppDimensions.onboardingButtonHeight,
                                  child: FilledButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            unawaited(
                                              sl<UserContextProvider>()
                                                  .recordAction(
                                                    'Auth primary button',
                                                  ),
                                            );
                                            _submitRegistration();
                                          },
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            LocalizationConstants.authNextKey
                                                .tr(),
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.spacing24),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (BuildContext context, AuthState state) {
                                final bool isLoading = state is AuthLoading;
                                return SizedBox(
                                  height: AppDimensions.onboardingButtonHeight,
                                  child: OutlinedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            unawaited(
                                              sl<UserContextProvider>()
                                                  .recordAction(
                                                    'Auth secondary button',
                                                  ),
                                            );
                                            _continueAsGuest();
                                          },
                                    child: Text(
                                      LocalizationConstants
                                          .authContinueAsGuestKey
                                          .tr(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.spacing16),
                            TextButton(
                              onPressed: () {
                                unawaited(
                                  sl<UserContextProvider>().recordAction(
                                    'Auth already have account button',
                                  ),
                                );
                                context.goTo(RouteNames.login);
                              },
                              child: Text(
                                LocalizationConstants.authAlreadyHaveAccountKey
                                    .tr(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spacing12),
                            const TermsPrivacyTextButton(),
                          ],
                        ),
                      ),
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
        const SizedBox(height: AppSpacing.spacing12),
      ],
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
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        validator: validator,
        onFieldSubmitted: onSubmitted,
        decoration: InputDecoration(hintText: hintText, suffixIcon: suffixIcon),
      ),
    );
  }
}
