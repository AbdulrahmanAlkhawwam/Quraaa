import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../../../core/assets/app_images.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/datasources/local/auth_journey_local_data_source.dart';

class AuthCredentialScreen extends StatefulWidget {
  const AuthCredentialScreen({
    super.key,
    required this.titleKey,
    required this.seenFlag,
    this.showIdentityFields = false,
    this.onBackPressed,
    required this.onPrimaryPressed,
    this.onPrimaryPressedWithData,
    required this.onSecondaryPressed,
    this.isLoading = false,
  });

  final String titleKey;
  final String seenFlag;
  final bool showIdentityFields;
  final VoidCallback? onBackPressed;
  final VoidCallback onPrimaryPressed;
  final Future<void> Function(AuthCredentialFormData data)?
  onPrimaryPressedWithData;
  final VoidCallback onSecondaryPressed;
  final bool isLoading;

  @override
  State<AuthCredentialScreen> createState() => _AuthCredentialScreenState();
}

class _AuthCredentialScreenState extends State<AuthCredentialScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  PhoneNumber? _phoneNumber;
  bool _isPhoneValid = false;
  bool _obscurePassword = true;

  AuthJourneyLocalDataSource get _authJourney =>
      sl<AuthJourneyLocalDataSource>();

  @override
  void initState() {
    super.initState();
    _markSeen();
  }

  Future<void> _markSeen() async {
    if (widget.seenFlag == 'auth') {
      await _authJourney.markAuthSeen();
      return;
    }
    if (widget.seenFlag == 'login') {
      await _authJourney.markLoginSeen();
      return;
    }
    if (widget.seenFlag == 'register') {
      await _authJourney.markRegisterSeen();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    AppSpacing.spacing24 +
                        context.bottomPadding /*+
                        context.bottomInsets*/,
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
                        if (widget.onBackPressed != null) ...[
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
                                widget.onBackPressed!();
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacing20),
                        ],
                        Text(
                          widget.titleKey.tr(),
                          textAlign: TextAlign.start,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.libraryGreen,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing32),
                        if (widget.showIdentityFields) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _AuthTextField(
                                  controller: _firstNameController,
                                  hintText: 'First name',
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (String? value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'First name is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.spacing12),
                              Expanded(
                                child: _AuthTextField(
                                  controller: _lastNameController,
                                  hintText: 'Last name',
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (String? value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Last name is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.spacing16),
                        ],
                        _LabeledField(
                          label: LocalizationConstants.authPhoneLabelKey.tr(),
                          child: InternationalPhoneNumberInput(
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
                            selectorConfig: SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                              setSelectorButtonAsPrefixIcon: true,
                              useBottomSheetSafeArea: true,
                            ),
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
                            initialValue: PhoneNumber(isoCode: 'SY'),
                            textFieldController: _phoneController,
                            keyboardType: TextInputType.phone,
                            textStyle: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            selectorTextStyle: AppTextStyles.bodyMedium
                                .copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                            inputDecoration: InputDecoration(
                              hintText: LocalizationConstants.authPhoneHintKey
                                  .tr(),
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              filled: true,
                              fillColor: AppColors.card,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.spacing20,
                                vertical: AppSpacing.spacing20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.radius24,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.primary100,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.radius24,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.primary100,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.radius24,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.primary400,
                                ),
                              ),
                            ),
                            onFieldSubmitted: (_) => _submit(),
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
                                    ? HugeIcons.strokeRoundedCancelCircle
                                    : HugeIcons.strokeRoundedEye,
                                color: AppColors.primary300,
                                size: 20,
                              ),
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing32),
                        SizedBox(
                          height: AppDimensions.onboardingButtonHeight,
                          child: FilledButton(
                            onPressed: widget.isLoading
                                ? null
                                : () {
                                    unawaited(
                                      sl<UserContextProvider>().recordAction(
                                        'Auth primary button',
                                      ),
                                    );
                                    _submit();
                                  },
                            child: widget.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(LocalizationConstants.authNextKey.tr()),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing24),
                        SizedBox(
                          height: AppDimensions.onboardingButtonHeight,
                          child: OutlinedButton(
                            onPressed: widget.isLoading
                                ? null
                                : () {
                                    unawaited(
                                      sl<UserContextProvider>().recordAction(
                                        'Auth secondary button',
                                      ),
                                    );
                                    widget.onSecondaryPressed();
                                  },
                            child: Text(
                              LocalizationConstants.authContinueAsGuestKey.tr(),
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

  void _submit() {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      unawaited(sl<UserContextProvider>().recordAction('Auth submit blocked'));
      return;
    }

    final PhoneNumber phoneNumber = _phoneNumber ?? PhoneNumber();
    final String normalizedPhone =
        phoneNumber.phoneNumber?.trim() ?? _phoneController.text.trim();

    if (widget.onPrimaryPressedWithData != null) {
      unawaited(
        sl<UserContextProvider>().recordAction('Auth submit with data'),
      );
      unawaited(
        widget.onPrimaryPressedWithData!(
          AuthCredentialFormData(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: normalizedPhone,
            password: _passwordController.text,
            phoneIsoCode: phoneNumber.isoCode,
            phoneDialCode: phoneNumber.dialCode,
          ),
        ),
      );
      return;
    }

    unawaited(
      sl<UserContextProvider>().recordAction('Auth submit without data'),
    );
    widget.onPrimaryPressed();
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
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.libraryGreen,
            fontWeight: FontWeight.w500,
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
          icon: HugeIcon(icon: icon, color: AppColors.textPrimary, size: 18),
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
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        // onSubmitted: onSubmitted,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing20,
            vertical: AppSpacing.spacing20,
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.radius24),
            borderSide: const BorderSide(color: AppColors.primary100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.radius24),
            borderSide: const BorderSide(color: AppColors.primary100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.radius24),
            borderSide: const BorderSide(color: AppColors.primary400),
          ),
        ),
      ),
    );
  }
}

class AuthCredentialFormData {
  const AuthCredentialFormData({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.password,
    this.phoneIsoCode,
    this.phoneDialCode,
  });

  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String password;
  final String? phoneIsoCode;
  final String? phoneDialCode;
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
