import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested();
}

sealed class AuthState {
  const AuthState();
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
  const AuthError(this.message);

  final String message;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(const AuthLoading());
      emit(const AuthSuccess());
    });
  }
}
