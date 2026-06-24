import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/connectivity/offline_route_guard.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../../../core/assets/app_images.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/widgets/phone_number_input.dart';
import '../../../onboarding/domain/entities/category.dart';
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
      child: const OfflineRouteGuard(child: _RegisterView()),
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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  PhoneNumber? _phoneNumber;
  bool _isPhoneValid = false;
  bool _obscurePassword = true;

  bool _isLoadingOnboarding = true;
  GenderSelection? _selectedGender;
  int? _birthYear;
  int? _birthMonth;
  int? _birthDay;
  List<String> _selectedCategoryIds = const <String>[];
  List<String> _validCategoryIds = const <String>[];

  String? _lastSubmittedPhone;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    unawaited(_authJourney.markRegisterSeen());
    unawaited(_loadOnboardingData());
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadOnboardingData() async {
    try {
      final OnboardingDraft draft = await _onboardingRepository.loadState();
      final List<Category> categories = await _onboardingRepository.getCategories();
      if (!mounted) return;
      setState(() {
        _selectedGender = draft.selectedGender;
        _birthYear = draft.birthYear;
        _birthMonth = draft.birthMonth;
        _birthDay = draft.birthDay;
        _selectedCategoryIds = draft.selectedCategoryIds ?? const <String>[];
        _validCategoryIds = categories.map((Category c) => c.id).toList();
        _isLoadingOnboarding = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingOnboarding = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_onFieldChanged);
    _lastNameController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isPhoneFormatValid {
    final String? normalized = _phoneNumber?.phoneNumber;
    return _isPhoneValid && normalized != null && normalized.startsWith('+');
  }

  String? get _firstNameError => Validators.validateName(
        _firstNameController.text,
        emptyError: LocalizationConstants.authFirstNameRequiredErrorKey.tr(),
        maxLengthError:
            LocalizationConstants.authFirstNameMaxLengthErrorKey.tr(),
      );

  String? get _lastNameError => Validators.validateName(
        _lastNameController.text,
        emptyError: LocalizationConstants.authLastNameRequiredErrorKey.tr(),
        maxLengthError:
            LocalizationConstants.authLastNameMaxLengthErrorKey.tr(),
      );

  String? get _phoneError => Validators.validatePhone(
        _phoneController.text,
        emptyError: LocalizationConstants.authPhoneRequiredErrorKey.tr(),
        formatError: LocalizationConstants.authPhoneFormatErrorKey.tr(),
        isValid: _isPhoneFormatValid,
      );

  String? get _passwordError => Validators.validatePassword(
        _passwordController.text,
        emptyError: LocalizationConstants.authPasswordRequiredErrorKey.tr(),
        minLengthError:
            LocalizationConstants.authPasswordMinLengthErrorKey.tr(),
        digitError: LocalizationConstants.authPasswordDigitErrorKey.tr(),
      );

  String? get _dateOfBirthError => Validators.validateDateOfBirth(
        year: _birthYear,
        month: _birthMonth,
        day: _birthDay,
        emptyError:
            LocalizationConstants.authDateOfBirthRequiredErrorKey.tr(),
        invalidError:
            LocalizationConstants.authDateOfBirthInvalidErrorKey.tr(),
      );

  String? get _genderError => Validators.validateGender(
        _selectedGender,
        invalidError: LocalizationConstants.authGenderInvalidErrorKey.tr(),
      );

  String? get _interestsError => Validators.validateInterests(
        categoryIds: _selectedCategoryIds,
        validCategoryIds: _validCategoryIds,
        emptyError: LocalizationConstants.authInterestsEmptyErrorKey.tr(),
        invalidError: LocalizationConstants.authInterestsInvalidErrorKey.tr(),
      );

  bool get _canSubmit {
    if (_isLoadingOnboarding) return false;
    return _firstNameError == null &&
        _lastNameError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _dateOfBirthError == null &&
        _genderError == null &&
        _interestsError == null;
  }

  Future<void> _continueAsUser() async {
    await _authJourney.markAuthenticatedSession();
    await sl<UserContextProvider>().setUser(
      id: 'registered-user',
      name: 'Registered user',
      subscriptionStatus: 'active',
    );
    if (!mounted) return;
    await _navigatePostRegister(context, phoneNumber: _lastSubmittedPhone);
  }

  Future<void> _continueAsGuest() async {
    await _authJourney.markGuestSession();
    await sl<UserContextProvider>().clearUser();
    if (!mounted) return;
    await _navigatePostRegister(context, phoneNumber: null);
  }

  Future<void> _navigatePostRegister(
    BuildContext context, {
    String? phoneNumber,
  }) async {
    context.goTo(
      RouteNames.otpVerification,
      extra: phoneNumber,
    );
  }

  Future<void> _submitRegistration() async {
    final bool isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || !_canSubmit) {
      unawaited(sl<UserContextProvider>().recordAction('Auth submit blocked'));
      return;
    }

    unawaited(sl<UserContextProvider>().recordAction('Auth submit with data'));

    final String formattedDateOfBirth =
        '${_birthYear.toString().padLeft(4, '0')}-${_birthMonth.toString().padLeft(2, '0')}-${_birthDay.toString().padLeft(2, '0')}';

    final PhoneNumber phoneNumber = _phoneNumber ?? PhoneNumber();
    final String normalizedPhone =
        phoneNumber.phoneNumber?.trim() ?? _phoneController.text.trim();

    _lastSubmittedPhone = normalizedPhone;

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: normalizedPhone,
        password: _passwordController.text,
        gender: _genderToApiValue(_selectedGender!),
        dateOfBirth: formattedDateOfBirth,
        categoryIds: _selectedCategoryIds,
      ),
    );
  }

  int _genderToApiValue(GenderSelection gender) {
    return switch (gender) {
      GenderSelection.boy => 1,
      GenderSelection.girl => 2,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        switch (state) {
          case AuthSuccess():
            unawaited(_navigatePostRegister(context, phoneNumber: _lastSubmittedPhone));
          case AuthError(:final error):
            context.showResolvedErrorSnackBar(error);
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
                              label: LocalizationConstants.authFirstNameLabelKey
                                  .tr(),
                              child: _AuthTextField(
                                controller: _firstNameController,
                                hintText: LocalizationConstants
                                    .authFirstNameHintKey
                                    .tr(),
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (String? value) =>
                                    Validators.validateName(
                                  value,
                                  emptyError: LocalizationConstants
                                      .authFirstNameRequiredErrorKey
                                      .tr(),
                                  maxLengthError: LocalizationConstants
                                      .authFirstNameMaxLengthErrorKey
                                      .tr(),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spacing16),
                            _LabeledField(
                              label: LocalizationConstants.authLastNameLabelKey
                                  .tr(),
                              child: _AuthTextField(
                                controller: _lastNameController,
                                hintText: LocalizationConstants
                                    .authLastNameHintKey
                                    .tr(),
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (String? value) =>
                                    Validators.validateName(
                                  value,
                                  emptyError: LocalizationConstants
                                      .authLastNameRequiredErrorKey
                                      .tr(),
                                  maxLengthError: LocalizationConstants
                                      .authLastNameMaxLengthErrorKey
                                      .tr(),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spacing16),
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
                                  validator: (String? value) =>
                                      Validators.validatePhone(
                                    value,
                                    emptyError: LocalizationConstants
                                        .authPhoneRequiredErrorKey
                                        .tr(),
                                    formatError: LocalizationConstants
                                        .authPhoneFormatErrorKey
                                        .tr(),
                                    isValid: _isPhoneFormatValid,
                                  ),
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
                                validator: (String? value) =>
                                    Validators.validatePassword(
                                  value,
                                  emptyError: LocalizationConstants
                                      .authPasswordRequiredErrorKey
                                      .tr(),
                                  minLengthError: LocalizationConstants
                                      .authPasswordMinLengthErrorKey
                                      .tr(),
                                  digitError: LocalizationConstants
                                      .authPasswordDigitErrorKey
                                      .tr(),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onSubmitted: (_) => _submitRegistration(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spacing12),
                            _PasswordChecklist(
                              password: _passwordController.text,
                            ),
                            const SizedBox(height: AppSpacing.spacing16),
                            _OnboardingValidationSummary(
                              isLoading: _isLoadingOnboarding,
                              dateOfBirthError: _dateOfBirthError,
                              genderError: _genderError,
                              interestsError: _interestsError,
                            ),
                            const SizedBox(height: AppSpacing.spacing32),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (BuildContext context, AuthState state) {
                                final bool isLoading = state is AuthLoading;
                                return SizedBox(
                                  height: AppDimensions.onboardingButtonHeight,
                                  child: FilledButton(
                                    onPressed: isLoading || !_canSubmit
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
    this.autovalidateMode,
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
  final AutovalidateMode? autovalidateMode;

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
        autovalidateMode: autovalidateMode,
        decoration: InputDecoration(hintText: hintText, suffixIcon: suffixIcon),
      ),
    );
  }
}

class _PasswordChecklist extends StatelessWidget {
  const _PasswordChecklist({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _PasswordRequirementItem(
          isMet: Validators.passwordNotEmpty(password),
          text: LocalizationConstants.authPasswordRequirementNotEmptyKey.tr(),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        _PasswordRequirementItem(
          isMet: Validators.passwordMinLength(password),
          text: LocalizationConstants.authPasswordRequirementMinLengthKey.tr(),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        _PasswordRequirementItem(
          isMet: Validators.passwordHasDigit(password),
          text: LocalizationConstants.authPasswordRequirementDigitKey.tr(),
        ),
      ],
    );
  }
}

class _PasswordRequirementItem extends StatelessWidget {
  const _PasswordRequirementItem({
    required this.isMet,
    required this.text,
  });

  final bool isMet;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        AnimatedContainer(
          duration: AppDurations.medium,
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMet ? AppColors.success500 : Colors.transparent,
            border: Border.all(
              color: isMet ? AppColors.success500 : AppColors.textSecondary,
              width: 1.5,
            ),
          ),
          child: AnimatedSwitcher(
            duration: AppDurations.medium,
            transitionBuilder: (
              Widget child,
              Animation<double> animation,
            ) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: isMet
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                    key: ValueKey<String>('check'),
                  )
                : const SizedBox.shrink(
                    key: ValueKey<String>('empty'),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.spacing12),
        AnimatedDefaultTextStyle(
          duration: AppDurations.medium,
          style: AppTextStyles.bodySmall.copyWith(
            color: isMet ? AppColors.success500 : AppColors.textSecondary,
          ),
          child: Text(text),
        ),
      ],
    );
  }
}

class _OnboardingValidationSummary extends StatelessWidget {
  const _OnboardingValidationSummary({
    required this.isLoading,
    this.dateOfBirthError,
    this.genderError,
    this.interestsError,
  });

  final bool isLoading;
  final String? dateOfBirthError;
  final String? genderError;
  final String? interestsError;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final List<String> errors = <String>[
      ?dateOfBirthError,
      ?genderError,
      ?interestsError,
    ];

    if (errors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: errors.map((String error) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.spacing8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.error_outline,
                color: AppColors.error500,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.spacing8),
              Expanded(
                child: Text(
                  error,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
