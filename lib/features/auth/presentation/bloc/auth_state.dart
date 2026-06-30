import 'package:equatable/equatable.dart';

sealed class AuthState with EquatableMixin {
  const AuthState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthSuccess extends AuthState {
  const AuthSuccess();
}

final class AuthError extends AuthState {
  const AuthError(this.error);

  final Object? error;

  @override
  List<Object?> get props => <Object?>[error];

  @override
  String toString() => 'AuthError(error: $error)';
}
