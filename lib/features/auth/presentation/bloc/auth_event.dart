part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  AuthLoginRequested({required this.phoneNumber, required this.password});

  final String phoneNumber;
  final String password;
}

class AuthRegisterRequested extends AuthEvent {
  AuthRegisterRequested({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.password,
    this.gender,
    this.dateOfBirth,
    this.categoryIds,
  });

  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? password;
  final int? gender;
  final String? dateOfBirth;
  final List<String>? categoryIds;
}

class AuthStarted extends AuthEvent {}

class AuthOnboardingRequested extends AuthEvent {}

class AuthLoginRequestedFromAuth extends AuthEvent {}
