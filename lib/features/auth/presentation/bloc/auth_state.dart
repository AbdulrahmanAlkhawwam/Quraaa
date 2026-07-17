part of 'auth_bloc.dart';

enum AuthStatus {
  init,
  loading,
  success,
  error,
  navigationLoading,
  navigateToOnboarding,
  navigateToLogin,
}

enum AuthNavigationDestination { onboarding, login }

@immutable
class AuthState with EquatableMixin {
  const AuthState({
    this.status = AuthStatus.init,
    this.error,
    this.destination,
    this.nextRoute,
    this.routeExtra,
    this.navigationSerial = 0,
    this.savedPhoneNumber,
    this.savedPhoneIsoCode,
    this.phoneSerial = 0,
  });

  final AuthStatus status;
  final Object? error;
  final AuthNavigationDestination? destination;
  final String? nextRoute;
  final Object? routeExtra;
  final int navigationSerial;
  final String? savedPhoneNumber;
  final String? savedPhoneIsoCode;
  final int phoneSerial;

  AuthState copyWith({
    AuthStatus? status,
    Object? error,
    AuthNavigationDestination? destination,
    String? nextRoute,
    Object? routeExtra,
    int? navigationSerial,
    String? savedPhoneNumber,
    String? savedPhoneIsoCode,
    int? phoneSerial,
    bool clearError = false,
    bool clearRouteExtra = false,
  }) => AuthState(
        status: status ?? this.status,
        error: clearError ? null : error ?? this.error,
        destination: destination ?? this.destination,
        nextRoute: nextRoute ?? this.nextRoute,
        routeExtra: clearRouteExtra ? null : routeExtra ?? this.routeExtra,
        navigationSerial: navigationSerial ?? this.navigationSerial,
        savedPhoneNumber: savedPhoneNumber ?? this.savedPhoneNumber,
        savedPhoneIsoCode: savedPhoneIsoCode ?? this.savedPhoneIsoCode,
        phoneSerial: phoneSerial ?? this.phoneSerial,
      );

  @override
  List<Object?> get props => <Object?>[
        status,
        error,
        destination,
        nextRoute,
        routeExtra,
        navigationSerial,
        savedPhoneNumber,
        savedPhoneIsoCode,
        phoneSerial,
      ];
}