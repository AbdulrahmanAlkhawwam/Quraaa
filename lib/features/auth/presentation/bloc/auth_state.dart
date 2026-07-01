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
  });

  final AuthStatus status;
  final Object? error;
  final AuthNavigationDestination? destination;

  AuthState copyWith({
    AuthStatus? status,
    Object? error,
    AuthNavigationDestination? destination,
  }) =>
      AuthState(
        status: status ?? this.status,
        error: error ?? this.error,
        destination: destination ?? this.destination,
      );

  @override
  List<Object?> get props => <Object?>[status, error, destination];
}
