/// Where the user is in the pre-home flow. Persisted so startup routing can
/// resume the same step after the app is killed.
enum AuthJourneyStage {
  auth,
  login,
  register,
  onboarding,
  onboardingAge,
  onboardingInterests,
  otpVerification,
  resetPassword,
  home,
}

/// Whether the current session belongs to a signed-in user or a guest.
enum AuthSessionMode { guest, authenticated }
