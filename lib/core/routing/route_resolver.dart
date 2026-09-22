import '../connectivity/connection_status.dart';
import '../connectivity/connectivity_service.dart';
import '../di/injection_container.dart';
import '../error_monitoring/user_context_provider.dart';
import '../utils/validators.dart';
import '../../features/auth/data/data_sources/auth_local_data_source.dart'
    show AuthLocalDataSource, AuthJourneyStage, AuthSessionMode;
import '../../features/onboarding/domain/entities/onboarding_draft.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../constants/app_routes.dart';

Future<String> resolveStartupRoute() async {
  final OnboardingRepository onboardingRepository = sl<OnboardingRepository>();
  final AuthLocalDataSource authJourney = sl<AuthLocalDataSource>();

  final OnboardingDraft onboardingDraft = await onboardingRepository
      .loadState();
  final AuthSessionMode? sessionMode = await authJourney.getSessionMode();
  final AuthJourneyStage? currentStage = await authJourney.getCurrentStage();

  if (sessionMode == AuthSessionMode.guest ||
      sessionMode == AuthSessionMode.authenticated) {
    return AppRoutes.home;
  }

  ConnectionStatus connectionStatus = ConnectionStatus.unknown;
  try {
    connectionStatus = await sl<ConnectivityService>().currentStatus();
  } catch (_) {
    // A connectivity lookup failure must not block normal startup routing.
  }

  if (connectionStatus == ConnectionStatus.disconnected) {
    try {
      await authJourney.markGuestSession();
    } catch (_) {
      // The user must still be able to enter the offline shell.
    }
    try {
      await sl<UserContextProvider>().clearUser();
    } catch (_) {
      // Monitoring context cleanup is best effort.
    }
    return AppRoutes.home;
  }

  if (currentStage != null) {
    return _normalizeStageRoute(currentStage, onboardingDraft);
  }

  if (_hasOnboardingProgress(onboardingDraft)) {
    return resolveRegistrationDraftRoute(onboardingDraft);
  }

  return AppRoutes.auth;
}

String resolveRegistrationDraftRoute(OnboardingDraft onboardingDraft) {
  if (!Validators.genderValid(onboardingDraft.selectedGender)) {
    return AppRoutes.onboarding;
  }

  if (!Validators.dateOfBirthAgeInRange(
    year: onboardingDraft.birthYear,
    month: onboardingDraft.birthMonth,
    day: onboardingDraft.birthDay,
  )) {
    return AppRoutes.onboardingAge;
  }

  if (!Validators.interestsNotEmpty(onboardingDraft.selectedCategoryIds) ||
      !onboardingDraft.completed) {
    return AppRoutes.onboardingInterests;
  }

  return AppRoutes.register;
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
    AuthJourneyStage.auth => AppRoutes.auth,
    AuthJourneyStage.login => AppRoutes.login,
    AuthJourneyStage.register => resolveRegistrationDraftRoute(onboardingDraft),
    AuthJourneyStage.onboarding => AppRoutes.onboarding,
    AuthJourneyStage.onboardingAge =>
      Validators.genderValid(onboardingDraft.selectedGender)
          ? AppRoutes.onboardingAge
          : AppRoutes.onboarding,
    AuthJourneyStage.onboardingInterests =>
      !Validators.genderValid(onboardingDraft.selectedGender)
          ? AppRoutes.onboarding
          : Validators.dateOfBirthAgeInRange(
              year: onboardingDraft.birthYear,
              month: onboardingDraft.birthMonth,
              day: onboardingDraft.birthDay,
            )
          ? AppRoutes.onboardingInterests
          : AppRoutes.onboardingAge,
    AuthJourneyStage.otpVerification => AppRoutes.otpVerification,
    AuthJourneyStage.resetPassword => AppRoutes.resetPassword,
    AuthJourneyStage.home => AppRoutes.home,
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
  AppRoutes.home,
  AppRoutes.auth,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.libraries,
  AppRoutes.stores,
  AppRoutes.userBooks,
  AppRoutes.audioBooks,
  AppRoutes.cart,
  AppRoutes.favorites,
  AppRoutes.bookAssistant,
  AppRoutes.search,
  AppRoutes.settings,
  AppRoutes.settingsPersonalFiles,
  AppRoutes.settingsChangePassword,
  AppRoutes.settingsAccountType,
  AppRoutes.subscriptionAccountType,
  AppRoutes.explorer,
  AppRoutes.pdfReader,
  AppRoutes.onboarding,
  AppRoutes.onboardingAge,
  AppRoutes.onboardingInterests,
  AppRoutes.notificationPermission,
  AppRoutes.locationPermission,
  AppRoutes.otpVerification,
  AppRoutes.forgotPassword,
  AppRoutes.resetPassword,
};
