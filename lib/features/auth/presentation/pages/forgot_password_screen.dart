import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/connectivity/connectivity_ui_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/widgets/phone_number_input.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../domain/use_cases/forgot_password_use_case.dart';
import '../widgets/auth_form_fields.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthLocalDataSource _authJourney = sl<AuthLocalDataSource>();
  final ForgotPasswordUseCase _forgotPasswordUseCase =
      sl<ForgotPasswordUseCase>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  PhoneNumber? _phoneNumber;
  bool _isPhoneValid = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final bool isOnline = await ensureOnline(context);
    if (!isOnline) return;

    final PhoneNumber phoneNumber = _phoneNumber ?? PhoneNumber();
    final String normalizedPhone =
        phoneNumber.phoneNumber?.trim() ?? _phoneController.text.trim();

    setState(() => _isSubmitting = true);

    final result = await _forgotPasswordUseCase(
      ForgotPasswordParams(phoneNumber: normalizedPhone),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    await result.fold(
      (failure) async {
        if (!mounted) return;
        context.showResolvedErrorSnackBar(failure);
      },
      (_) async {
        await _authJourney.saveLastPhoneNumber(
          normalizedPhone,
          _phoneNumber?.isoCode ?? 'SY',
        );
        if (!mounted) return;
        context.showSuccessSnackBar(
          message: Message(
            title: '',
            value: LocalizationConstants.authForgotPasswordSuccessKey.tr(),
          ),
        );
        context.goTo(RouteNames.resetPassword, extra: normalizedPhone);
      },
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
                      LocalizationConstants.authForgotPasswordTitleKey.tr(),
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
                LocalizationConstants.authForgotPasswordDescriptionKey.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing24),
              AuthLabeledField(
                label: LocalizationConstants.authPhoneLabelKey.tr(),
                child: PhoneNumberInput(
                  controller: _phoneController,
                  initialValue: PhoneNumber(isoCode: 'SY'),
                  countries: const <String>['SY'],
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
                      return LocalizationConstants.authPhoneHintKey.tr();
                    }
                    if (!_isPhoneValid || _phoneNumber?.isoCode == null) {
                      return LocalizationConstants.authPhoneValidErrorKey.tr();
                    }
                    return null;
                  },
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  onFieldSubmitted: _onSubmit,
                  hintText: LocalizationConstants.authPhoneHintKey.tr(),
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
                          LocalizationConstants.authForgotPasswordButtonKey
                              .tr(),
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
