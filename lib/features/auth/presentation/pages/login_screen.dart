import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/datasources/local/auth_journey_local_data_source.dart';
import '../widgets/auth_credential_screen.dart';
import '../../../../features/onboarding/domain/repositories/onboarding_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthJourneyLocalDataSource _authJourney =
      sl<AuthJourneyLocalDataSource>();
  final OnboardingRepository _onboardingRepository =
      sl<OnboardingRepository>();

  @override
  void initState() {
    super.initState();
    unawaited(_authJourney.markLoginSeen());
  }

  Future<void> _goBack() async {
    final AuthJourneyStage? previousStage = await _authJourney.getPreviousStage();
    if (_shouldResumeOnboarding(previousStage)) {
      await _onboardingRepository.resetCompletion();
    }
    await _authJourney.saveJourneyStage(
      previousStage ?? AuthJourneyStage.auth,
      previousStage: AuthJourneyStage.login,
    );
    if (!mounted) {
      return;
    }
    context.goTo(_routeForStage(previousStage));
  }

  Future<void> _continueAsUser(AuthCredentialFormData data) async {
    await _authJourney.markAuthenticatedSession();
    await sl<UserContextProvider>().setUser(
      id: data.phoneNumber,
      name: data.phoneNumber,
      phone: data.phoneNumber,
      subscriptionStatus: 'active',
    );
    if (!mounted) {
      return;
    }
    context.goTo(RouteNames.home);
  }

  Future<void> _continueAsGuest() async {
    await _authJourney.markGuestSession();
    await sl<UserContextProvider>().clearUser();
    if (!mounted) {
      return;
    }
    context.goTo(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return AuthCredentialScreen(
      titleKey: LocalizationConstants.authLoginTitleKey,
      seenFlag: 'login',
      onBackPressed: _goBack,
      onPrimaryPressedWithData: _continueAsUser,
      onPrimaryPressed: () {},
      onSecondaryPressed: _continueAsGuest,
    );
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
