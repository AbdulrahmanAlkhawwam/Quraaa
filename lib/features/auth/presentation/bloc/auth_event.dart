part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {
  const AuthEvent();
}

class AuthLoginScreenStarted extends AuthEvent {
  const AuthLoginScreenStarted();
}

class AuthRegisterScreenStarted extends AuthEvent {
  const AuthRegisterScreenStarted();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.phoneNumber,
    required this.password,
    this.phoneIsoCode,
  });

  final String phoneNumber;
  final String password;
  final String? phoneIsoCode;
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.phoneIsoCode,
    this.password,
    this.gender,
    this.dateOfBirth,
    this.categoryIds,
  });

  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? phoneIsoCode;
  final String? password;
  final int? gender;
  final String? dateOfBirth;
  final List<String>? categoryIds;
}

class AuthGuestRequested extends AuthEvent {
  const AuthGuestRequested();
}

class AuthActionTracked extends AuthEvent {
  const AuthActionTracked(this.action);

  final String action;
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthOnboardingRequested extends AuthEvent {
  const AuthOnboardingRequested();
}

class AuthLoginRequestedFromAuth extends AuthEvent {
  const AuthLoginRequestedFromAuth();
}