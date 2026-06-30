import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../onboarding/domain/entities/gender_selection.dart';
import '../../data/datasources/local/auth_journey_local_data_source.dart';
import '../../../../features/onboarding/domain/entities/onboarding_draft.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../widgets/auth_credential_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthJourneyLocalDataSource _authJourney =
      sl<AuthJourneyLocalDataSource>();
  final OnboardingRepository _onboardingRepository =
      sl<OnboardingRepository>();
  final AuthRepository _authRepository = sl<AuthRepository>();

  @override
  void initState() {
    super.initState();
    unawaited(_authJourney.markRegisterSeen());
  }

  Future<void> _goBack() async {
    final AuthJourneyStage? previousStage = await _authJourney.getPreviousStage();
    if (_shouldResumeOnboarding(previousStage)) {
      await _onboardingRepository.resetCompletion();
    }
    await _authJourney.saveJourneyStage(
      previousStage ?? AuthJourneyStage.auth,
      previousStage: AuthJourneyStage.register,
    );
    if (!mounted) {
      return;
    }
    context.goTo(_routeForStage(previousStage));
  }

  Future<void> _continueAsUser() async {
    await _authJourney.markAuthenticatedSession();
    if (!mounted) {
      return;
    }
    context.goTo(RouteNames.home);
  }

  Future<void> _continueAsGuest() async {
    await _authJourney.markGuestSession();
    if (!mounted) {
      return;
    }
    context.goTo(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return AuthCredentialScreen(
      titleKey: LocalizationConstants.authRegisterTitleKey,
      seenFlag: 'register',
      showIdentityFields: true,
      onBackPressed: _goBack,
      onPrimaryPressed: _continueAsUser,
      onPrimaryPressedWithData: _submitRegistration,
      onSecondaryPressed: _continueAsGuest,
    );
  }

  Future<void> _submitRegistration(AuthCredentialFormData data) async {
    final OnboardingDraft onboardingDraft =
        await _onboardingRepository.loadState();
    final GenderSelection? selectedGender = onboardingDraft.selectedGender;
    final int? birthYear = onboardingDraft.birthYear;
    final int? birthMonth = onboardingDraft.birthMonth;
    final int? birthDay = onboardingDraft.birthDay;

    if (selectedGender == null ||
        birthYear == null ||
        birthMonth == null ||
        birthDay == null) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar(
        message: const Message(
          title: 'Registration incomplete',
          value: 'Please finish onboarding before registering.',
        ),
      );
      return;
    }

    final String formattedDateOfBirth =
        '${birthYear.toString().padLeft(4, '0')}-${birthMonth.toString().padLeft(2, '0')}-${birthDay.toString().padLeft(2, '0')}';
    final List<String> interests = onboardingDraft.selectedInterests
        .map((interest) => interest.key)
        .toList(growable: false);

    try {
      final tokens = await _authRepository.register(
        firstName: data.firstName,
        lastName: data.lastName,
        phoneNumber: data.phoneNumber,
        password: data.password,
        gender: _genderToApiValue(selectedGender),
        dateOfBirth: formattedDateOfBirth,
        interests: interests,
      );

      await _authJourney.markAuthenticatedSession(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      if (!mounted) {
        return;
      }
      context.goTo(RouteNames.home);
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar(
        message: Message(
          title: 'Registration failed',
          value: error.toString(),
        ),
      );
    }
  }

  int _genderToApiValue(GenderSelection gender) {
    return switch (gender) {
      GenderSelection.boy => 0,
      GenderSelection.girl => 1,
    };
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
}
