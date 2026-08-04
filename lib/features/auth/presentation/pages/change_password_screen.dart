import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/connectivity/connectivity_ui_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../bloc/change_password_cubit.dart';
import '../widgets/auth_form_fields.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!await ensureOnline(context) || !context.mounted) return;

    await context.read<ChangePasswordCubit>().changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );
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

  String? _validateNewPassword(String? value) {
    final String? validation = _validatePassword(value);
    if (validation != null) return validation;
    if (value == _oldPasswordController.text) {
      return LocalizationConstants.authChangePasswordSamePasswordKey.tr();
    }
    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return LocalizationConstants.authPasswordRequiredErrorKey.tr();
    }
    if (value != _newPasswordController.text) {
      return LocalizationConstants.authChangePasswordMismatchKey.tr();
    }
    return null;
  }

  Widget _visibilityButton({
    required bool obscure,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: HugeIcon(
        icon: obscure
            ? HugeIcons.strokeRoundedViewOff
            : HugeIcons.strokeRoundedView,
        color: AppColors.primary300,
        size: 20,
      ),
    );
  }

  void _onStateChanged(BuildContext context, ChangePasswordState state) {
    if (state.status == ChangePasswordStatus.failure) {
      context.showResolvedErrorSnackBar(state.error);
      return;
    }
    if (state.status == ChangePasswordStatus.success) {
      context.showSuccessSnackBar(
        message: Message(
          title: '',
          value: LocalizationConstants.authChangePasswordSuccessKey.tr(),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChangePasswordCubit>(
      create: (_) => sl<ChangePasswordCubit>(),
      child: Builder(
        builder: (BuildContext context) =>
            BlocListener<ChangePasswordCubit, ChangePasswordState>(
              listener: _onStateChanged,
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
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                context.isRTL
                                    ? Icons.arrow_forward_ios
                                    : Icons.arrow_back_ios,
                                color: context.isDark
                                    ? AppColors.primary300
                                    : AppColors.libraryGreen,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                LocalizationConstants.authChangePasswordTitleKey
                                    .tr(),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.h3.copyWith(
                                  color: context.isDark
                                      ? AppColors.primary300
                                      : AppColors.libraryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.spacing48),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.spacing32),
                        Text(
                          LocalizationConstants.authChangePasswordDescriptionKey
                              .tr(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.appTextTertiary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing24),
                        AuthLabeledField(
                          label: LocalizationConstants
                              .authChangePasswordOldPasswordLabelKey
                              .tr(),
                          child: AuthTextField(
                            controller: _oldPasswordController,
                            hintText: LocalizationConstants
                                .authChangePasswordOldPasswordHintKey
                                .tr(),
                            obscureText: _obscureOldPassword,
                            textInputAction: TextInputAction.next,
                            suffixIcon: _visibilityButton(
                              obscure: _obscureOldPassword,
                              onPressed: () => setState(
                                () =>
                                    _obscureOldPassword = !_obscureOldPassword,
                              ),
                            ),
                            validator: _validatePassword,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing20),
                        AuthLabeledField(
                          label: LocalizationConstants
                              .authChangePasswordNewPasswordLabelKey
                              .tr(),
                          child: AuthTextField(
                            controller: _newPasswordController,
                            hintText: LocalizationConstants
                                .authChangePasswordNewPasswordHintKey
                                .tr(),
                            obscureText: _obscureNewPassword,
                            textInputAction: TextInputAction.next,
                            suffixIcon: _visibilityButton(
                              obscure: _obscureNewPassword,
                              onPressed: () => setState(
                                () =>
                                    _obscureNewPassword = !_obscureNewPassword,
                              ),
                            ),
                            validator: _validateNewPassword,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing20),
                        AuthLabeledField(
                          label: LocalizationConstants
                              .authChangePasswordConfirmPasswordLabelKey
                              .tr(),
                          child: AuthTextField(
                            controller: _confirmPasswordController,
                            hintText: LocalizationConstants
                                .authChangePasswordConfirmPasswordHintKey
                                .tr(),
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            suffixIcon: _visibilityButton(
                              obscure: _obscureConfirmPassword,
                              onPressed: () => setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              ),
                            ),
                            validator: _validateConfirmation,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onSubmitted: (_) => _submit(context),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing32),
                        BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                          builder:
                              (
                                BuildContext context,
                                ChangePasswordState state,
                              ) {
                                return SizedBox(
                                  height: AppDimensions.onboardingButtonHeight,
                                  child: FilledButton(
                                    onPressed: state.isLoading
                                        ? null
                                        : () => _submit(context),
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
                                                .authChangePasswordButtonKey
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
      ),
    );
  }
}
