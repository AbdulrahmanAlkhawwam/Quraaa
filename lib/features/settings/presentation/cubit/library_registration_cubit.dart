import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../domain/entities/library_registration.dart';
import '../../domain/use_cases/request_library_registration_use_case.dart';

sealed class LibraryRegistrationState {
  const LibraryRegistrationState();
}

final class LibraryRegistrationInitial extends LibraryRegistrationState {
  const LibraryRegistrationInitial();
}

final class LibraryRegistrationLoading extends LibraryRegistrationState {
  const LibraryRegistrationLoading();
}

final class LibraryRegistrationReady extends LibraryRegistrationState {
  const LibraryRegistrationReady(this.registration);

  final LibraryRegistration registration;
}

final class LibraryRegistrationFailure extends LibraryRegistrationState {
  const LibraryRegistrationFailure(this.error);

  final Object error;
}

class LibraryRegistrationCubit extends Cubit<LibraryRegistrationState> {
  LibraryRegistrationCubit(this._requestRegistration)
      : super(const LibraryRegistrationInitial());

  final RequestLibraryRegistrationUseCase _requestRegistration;

  Future<void> requestRegistration() async {
    if (state is LibraryRegistrationLoading) return;
    emit(const LibraryRegistrationLoading());

    final Result<LibraryRegistration> result = await _requestRegistration(
      const NoParams(),
    );
    switch (result) {
      case Success<LibraryRegistration>(value: final registration):
        emit(LibraryRegistrationReady(registration));
      case ResultFailure<LibraryRegistration>(
          message: final message,
          cause: final cause,
        ):
        emit(LibraryRegistrationFailure(cause ?? message));
    }
  }

  void reset() => emit(const LibraryRegistrationInitial());
}
