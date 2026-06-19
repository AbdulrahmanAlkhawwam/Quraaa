
sealed class AuthEvent {
  const AuthEvent();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.phoneNumber, required this.password});

  final String phoneNumber;
  final String password;
}

final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.password,
    this.gender,
    this.dateOfBirth,
    this.interests,
  });

  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? password;
  final int? gender;
  final String? dateOfBirth;
  final List<String>? interests;
}