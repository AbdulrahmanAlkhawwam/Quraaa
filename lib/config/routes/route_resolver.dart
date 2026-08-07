import '../../core/di/injection_container.dart';
import '../../core/utils/validators.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    show AuthLocalDataSource, AuthJourneyStage, AuthSessionMode;
import '../../features/onboarding/domain/entities/onboarding_draft.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import 'route_names.dart';

Future<String> resolveStartupRoute() async {
  final OnboardingRepository onboardingRepository = sl<OnboardingRepository>();
  final AuthLocalDataSource authJourney = sl<AuthLocalDataSource>();

  final OnboardingDraft onboardingDraft = await onboardingRepository
      .loadState();
  final AuthSessionMode? sessionMode = await authJourney.getSessionMode();
  final AuthJourneyStage? currentStage = await authJourney.getCurrentStage();

  if (sessionMode == AuthSessionMode.guest ||
      sessionMode == AuthSessionMode.authenticated) {
    return RouteNames.home;
  }

  if (currentStage != null) {
    return _normalizeStageRoute(currentStage, onboardingDraft);
  }

  if (_hasOnboardingProgress(onboardingDraft)) {
    return resolveRegistrationDraftRoute(onboardingDraft);
  }

  return RouteNames.auth;
}

String resolveRegistrationDraftRoute(OnboardingDraft onboardingDraft) {
  if (!Validators.genderValid(onboardingDraft.selectedGender)) {
    return RouteNames.onboarding;
  }

  if (!Validators.dateOfBirthAgeInRange(
    year: onboardingDraft.birthYear,
    month: onboardingDraft.birthMonth,
    day: onboardingDraft.birthDay,
  )) {
    return RouteNames.onboardingAge;
  }

  if (!Validators.interestsNotEmpty(onboardingDraft.selectedCategoryIds) ||
      !onboardingDraft.completed) {
    return RouteNames.onboardingInterests;
  }

  return RouteNames.register;
}

bool _hasOnboardingProgress(OnboardingDraft onboardingDraft) {
  return onboardingDraft.completed ||
      onboardingDraft.selectedGender != null ||
      (onboardingDraft.selectedCategoryIds != null &&
          onboardingDraft.selectedCategoryIds!.isNotEmpty) ||
      onboardingDraft.birthYear != null ||
      onboardingDraft.birthMonth != null ||
      onboardingDraft.birthDay != null;
}

String _normalizeStageRoute(
  AuthJourneyStage stage,
  OnboardingDraft onboardingDraft,
) {
  return switch (stage) {
    AuthJourneyStage.auth => RouteNames.auth,
    AuthJourneyStage.login => RouteNames.login,
    AuthJourneyStage.register => resolveRegistrationDraftRoute(onboardingDraft),
    AuthJourneyStage.onboarding => RouteNames.onboarding,
    AuthJourneyStage.onboardingAge =>
      Validators.genderValid(onboardingDraft.selectedGender)
          ? RouteNames.onboardingAge
          : RouteNames.onboarding,
    AuthJourneyStage.onboardingInterests =>
      !Validators.genderValid(onboardingDraft.selectedGender)
          ? RouteNames.onboarding
          : Validators.dateOfBirthAgeInRange(
              year: onboardingDraft.birthYear,
              month: onboardingDraft.birthMonth,
              day: onboardingDraft.birthDay,
            )
          ? RouteNames.onboardingInterests
          : RouteNames.onboardingAge,
    AuthJourneyStage.otpVerification => RouteNames.otpVerification,
    AuthJourneyStage.resetPassword => RouteNames.resetPassword,
    AuthJourneyStage.home => RouteNames.home,
  };
}

String? resolveBridgeRoute(String? targetRoute) {
  if (targetRoute == null || targetRoute.isEmpty) {
    return null;
  }

  final String decodedRoute = Uri.decodeComponent(targetRoute);
  return _knownRoutes.contains(decodedRoute) ? decodedRoute : null;
}

const Set<String> _knownRoutes = <String>{
  RouteNames.home,
  RouteNames.auth,
  RouteNames.login,
  RouteNames.register,
  RouteNames.libraries,
  RouteNames.stores,
  RouteNames.userBooks,
  RouteNames.audioBooks,
  RouteNames.cart,
  RouteNames.favorites,
  RouteNames.bookAssistant,
  RouteNames.search,
  RouteNames.settings,
  RouteNames.settingsPersonalFiles,
  RouteNames.settingsChangePassword,
  RouteNames.settingsAccountType,
  RouteNames.subscriptionAccountType,
  RouteNames.explorer,
  RouteNames.pdfReader,
  RouteNames.onboarding,
  RouteNames.onboardingAge,
  RouteNames.onboardingInterests,
  RouteNames.notificationPermission,
  RouteNames.locationPermission,
  RouteNames.otpVerification,
  RouteNames.forgotPassword,
  RouteNames.resetPassword,
};
