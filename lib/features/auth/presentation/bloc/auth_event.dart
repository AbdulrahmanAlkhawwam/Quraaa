import 'package:equatable/equatable.dart';

sealed class AuthEvent with EquatableMixin {
  const AuthEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.phoneNumber, required this.password});

  final String phoneNumber;
  final String password;

  @override
  List<Object?> get props => <Object?>[phoneNumber, password];
}

final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
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

  @override
  List<Object?> get props => <Object?>[
        firstName,
        lastName,
        phoneNumber,
        password,
        gender,
        dateOfBirth,
        categoryIds,
      ];
}
