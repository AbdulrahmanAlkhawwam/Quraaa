import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../domain/entities/library_profile.dart';
import '../../domain/entities/library_registration.dart';
import '../../domain/use_cases/get_library_profile_use_case.dart';
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

final class LibraryProfileLoading extends LibraryRegistrationState {
  const LibraryProfileLoading();
}

final class LibraryProfileReady extends LibraryRegistrationState {
  const LibraryProfileReady(this.profile);

  final LibraryProfile profile;
}

final class LibraryRegistrationFailure extends LibraryRegistrationState {
  const LibraryRegistrationFailure(this.error);

  final Object error;
}

class LibraryRegistrationCubit extends Cubit<LibraryRegistrationState> {
  LibraryRegistrationCubit(this._requestRegistration, [this._getLibraryProfile])
      : super(const LibraryRegistrationInitial());

  final RequestLibraryRegistrationUseCase _requestRegistration;
  final GetLibraryProfileUseCase? _getLibraryProfile;

  Future<void> loadProfile() async {
    if (_getLibraryProfile == null) return;
    if (state is LibraryRegistrationLoading || state is LibraryProfileLoading) {
      return;
    }
    emit(const LibraryProfileLoading());
    final Result<LibraryProfile?> result = await _getLibraryProfile!(
      const NoParams(),
    );
    if (isClosed) return;
    switch (result) {
      case Success<LibraryProfile?>(value: final profile):
        emit(
          profile == null
              ? const LibraryRegistrationInitial()
              : LibraryProfileReady(profile),
        );
      case ResultFailure<LibraryProfile?>(
          message: final message,
          cause: final cause,
        ):
        emit(LibraryRegistrationFailure(cause ?? message));
    }
  }

  Future<void> requestRegistration() async {
    if (state is LibraryRegistrationLoading || state is LibraryProfileLoading) {
      return;
    }
    emit(const LibraryRegistrationLoading());
    final Result<LibraryRegistration> result = await _requestRegistration(
      const NoParams(),
    );
    if (isClosed) return;
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
