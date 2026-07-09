import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../core/connectivity/connectivity_ui_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/widgets/phone_number_input.dart';
import '../bloc/auth_recovery_cubit.dart';
import '../widgets/auth_form_fields.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final AuthRecoveryCubit _recoveryCubit = sl<AuthRecoveryCubit>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  PhoneNumber? _phoneNumber;
  bool _isPhoneValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _recoveryCubit.close();
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

    await _recoveryCubit.requestPasswordReset(
      phoneNumber: normalizedPhone,
      phoneIsoCode: _phoneNumber?.isoCode ?? 'SY',
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

    if (state.success == AuthRecoverySuccess.forgotPasswordSent) {
      context.showSuccessSnackBar(
        message: Message(
          title: '',
          value: LocalizationConstants.authForgotPasswordSuccessKey.tr(),
        ),
      );
    }
    context.goTo(state.nextRoute!, extra: state.routeExtra);
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
                          LocalizationConstants
                              .authForgotPasswordTitleKey
                              .tr(),
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
                    LocalizationConstants
                        .authForgotPasswordDescriptionKey
                        .tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.appTextTertiary,
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
                          return LocalizationConstants.authPhoneValidErrorKey
                              .tr();
                        }
                        return null;
                      },
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      onFieldSubmitted: _onSubmit,
                      hintText: LocalizationConstants.authPhoneHintKey.tr(),
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
                                      .authForgotPasswordButtonKey
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
