import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/connectivity/connectivity_ui_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/widgets/phone_number_input.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_form_fields.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final AuthLocalDataSource _authJourney = sl<AuthLocalDataSource>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  PhoneNumber? _phoneNumber;
  PhoneNumber? _initialPhoneNumber;
  bool _isPhoneValid = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    unawaited(_authJourney.markLoginSeen());
    unawaited(_loadLastPhoneNumber());
  }

  Future<void> _loadLastPhoneNumber() async {
    final String? phone = await _authJourney.getLastPhoneNumber();
    final String? isoCode = await _authJourney.getLastPhoneIsoCode();
    if (!mounted) return;
    if (phone != null && phone.isNotEmpty) {
      _initialPhoneNumber = PhoneNumber(
        phoneNumber: phone,
        isoCode: isoCode ?? 'SY',
      );
      _phoneNumber = _initialPhoneNumber;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continueAsUser() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      unawaited(sl<UserContextProvider>().recordAction('Auth submit blocked'));
      return;
    }

    final bool isOnline = await ensureOnline(context);
    if (!isOnline) {
      unawaited(sl<UserContextProvider>().recordAction('Auth submit offline'));
      return;
    }

    final PhoneNumber phoneNumber = _phoneNumber ?? PhoneNumber();
    final String normalizedPhone =
        phoneNumber.phoneNumber?.trim() ?? _phoneController.text.trim();

    unawaited(sl<UserContextProvider>().recordAction('Auth submit with data'));

    await _authJourney.saveLastPhoneNumber(
      normalizedPhone,
      _phoneNumber?.isoCode ?? 'SY',
    );

    if (!mounted) return;

    context.read<AuthBloc>().add(
      AuthLoginRequested(
        phoneNumber: normalizedPhone,
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _continueAsGuest() async {
    await _authJourney.markGuestSession();
    await sl<UserContextProvider>().clearUser();
    if (!mounted) return;
    await _navigatePostAuth(context);
  }

  Future<void> _navigatePostAuth(BuildContext context) async {
    final bool locationSeen = await _authJourney.isLocationPermissionSeen();
    if (!context.mounted) return;
    if (locationSeen) {
      final bool notificationSeen = await _authJourney
          .isNotificationPermissionSeen();
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        switch (state.status) {
          case AuthStatus.success:
            unawaited(_navigatePostAuth(context));
          case AuthStatus.error:
            context.showResolvedErrorSnackBar(state.error);
          case _:
            break;
        }
      },
      child: PopScope(
        canPop: false,
        child: Form(
          key: _formKey,
          child: AppLayout(
            expandContent: true,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    LocalizationConstants.authLoginTitleKey.tr(),
                    textAlign: TextAlign.start,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.libraryGreen,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing32),
                  AuthLabeledField(
                    label: LocalizationConstants.authPhoneLabelKey.tr(),
                    child: PhoneNumberInput(
                      controller: _phoneController,
                      initialValue:
                          _initialPhoneNumber ?? PhoneNumber(isoCode: 'SY'),
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
                      onFieldSubmitted: _continueAsUser,
                      hintText: LocalizationConstants.authPhoneHintKey.tr(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing16),
                  AuthLabeledField(
                    label: LocalizationConstants.authPasswordLabelKey.tr(),
                    child: AuthTextField(
                      controller: _passwordController,
                      hintText: LocalizationConstants.authPasswordHintKey.tr(),
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
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () {
                        unawaited(
                          sl<UserContextProvider>().recordAction(
                            'Auth forgot password button',
                          ),
                        );
                        context.goTo(RouteNames.forgotPassword);
                      },
                      child: Text(
                        LocalizationConstants.authPasswordForgotKey.tr(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.libraryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing16),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (BuildContext context, AuthState state) {
                      return SizedBox(
                        height: AppDimensions.onboardingButtonHeight,
                        child: FilledButton(
                          onPressed: state.status == AuthStatus.loading
                              ? null
                              : () {
                                  unawaited(
                                    sl<UserContextProvider>().recordAction(
                                      'Auth primary button',
                                    ),
                                  );
                                  _continueAsUser();
                                },
                          child: state.status == AuthStatus.loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.card,
                                  ),
                                )
                              : Text(LocalizationConstants.authNextKey.tr()),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.spacing24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (BuildContext context, AuthState state) {
                      return SizedBox(
                        height: AppDimensions.onboardingButtonHeight,
                        child: OutlinedButton(
                          onPressed: state.status == AuthStatus.loading
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
                            LocalizationConstants.authContinueAsGuestKey.tr(),
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
                          'Auth create new account button',
                        ),
                      );
                      context.goTo(RouteNames.register);
                    },
                    child: Text(
                      LocalizationConstants.authCreateNewAccountKey.tr(),
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
    );
  }
}
