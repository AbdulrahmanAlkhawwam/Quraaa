import '../../core/di/injection_container.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    show AuthLocalDataSource, AuthJourneyStage, AuthSessionMode;
import '../../features/onboarding/domain/entities/onboarding_draft.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import 'route_names.dart';

Future<String> resolveStartupRoute() async {
  final OnboardingRepository onboardingRepository = sl<OnboardingRepository>();
  final AuthLocalDataSource authJourney =
      sl<AuthLocalDataSource>();

  final OnboardingDraft onboardingDraft = await onboardingRepository.loadState();
  final AuthSessionMode? sessionMode = await authJourney.getSessionMode();
  final AuthJourneyStage? currentStage = await authJourney.getCurrentStage();

  if (sessionMode == AuthSessionMode.guest ||
      sessionMode == AuthSessionMode.authenticated) {
    return RouteNames.home;
  }

  if (onboardingDraft.completed) {
    return RouteNames.register;
  }

  if (currentStage != null) {
    return _normalizeStageRoute(currentStage);
  }

  if (_hasOnboardingProgress(onboardingDraft)) {
    return _deriveRouteFromDraft(onboardingDraft);
  }

  return RouteNames.auth;
}

String _deriveRouteFromDraft(OnboardingDraft onboardingDraft) {
  if (onboardingDraft.completed) {
    return RouteNames.register;
  }

  if (onboardingDraft.selectedGender == null) {
    return RouteNames.onboarding;
  }

  final bool hasBirthDate = onboardingDraft.birthYear != null &&
      onboardingDraft.birthMonth != null &&
      onboardingDraft.birthDay != null;
  if (!hasBirthDate) {
    return RouteNames.onboardingAge;
  }

  if (onboardingDraft.selectedInterests.isEmpty) {
    return RouteNames.onboardingInterests;
  }

  return RouteNames.register;
}

bool _hasOnboardingProgress(OnboardingDraft onboardingDraft) {
  return onboardingDraft.completed ||
      onboardingDraft.selectedGender != null ||
      onboardingDraft.selectedInterests.isNotEmpty ||
      onboardingDraft.birthYear != null ||
      onboardingDraft.birthMonth != null ||
      onboardingDraft.birthDay != null;
}

String _normalizeStageRoute(AuthJourneyStage stage) {
  return switch (stage) {
    AuthJourneyStage.auth => RouteNames.auth,
    AuthJourneyStage.login => RouteNames.login,
    AuthJourneyStage.register => RouteNames.register,
    AuthJourneyStage.onboarding => RouteNames.onboarding,
    AuthJourneyStage.onboardingAge => RouteNames.onboardingAge,
    AuthJourneyStage.onboardingInterests => RouteNames.onboardingInterests,
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
  RouteNames.onboarding,
  RouteNames.onboardingAge,
  RouteNames.onboardingInterests,
};
