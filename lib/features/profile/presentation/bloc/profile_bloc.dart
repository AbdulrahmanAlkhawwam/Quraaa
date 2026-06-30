import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connectivity/connection_status.dart';
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/datasources/user_local_datasource.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../data/datasources/profile_local_data_source.dart';
import '../../data/models/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC that loads the authenticated user's profile from the backend and keeps
/// the latest successful response cached for offline use.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required this.profileRepository,
    required this.authRepository,
    required this.authLocalDataSource,
    required this.userLocalDataSource,
    required this.connectivityService,
    required this.profileLocalDataSource,
  }) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
  }

  final ProfileRepository profileRepository;
  final AuthRepository authRepository;
  final AuthLocalDataSource authLocalDataSource;
  final UserLocalDataSource userLocalDataSource;
  final ConnectivityService connectivityService;
  final ProfileLocalDataSource profileLocalDataSource;

  /// Loads the user's profile when the device is online and the user is
  /// authenticated. Falls back to the cached profile when offline.
  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));

    final String? accessToken = await authLocalDataSource.getAccessToken();
    final String? refreshToken = await authLocalDataSource.getRefreshToken();

    // Missing tokens mean the user is not authenticated; stay idle.
    if (_isNullOrEmpty(accessToken) || _isNullOrEmpty(refreshToken)) {
      emit(state.copyWith(loading: false));
      return;
    }

    final ConnectionStatus connectionStatus =
        await connectivityService.currentStatus();

    if (connectionStatus == ConnectionStatus.disconnected) {
      await _loadCachedProfile(emit);
      return;
    }

    await _fetchProfileWithRefreshRetry(
      emit: emit,
      refreshToken: refreshToken!,
    );
  }

  Future<void> _loadCachedProfile(Emitter<ProfileState> emit) async {
    try {
      final ProfileModel? cachedProfile =
          await profileLocalDataSource.getCachedProfile();
      emit(state.copyWith(
        loading: false,
        profile: cachedProfile,
      ));
    } catch (error) {
      emit(state.copyWith(
        loading: false,
        error: const NoInternetFailure(),
      ));
    }
  }

  Future<void> _fetchProfileWithRefreshRetry({
    required Emitter<ProfileState> emit,
    required String refreshToken,
  }) async {
    try {
      final ProfileModel profile = await profileRepository.getMyProfile();
      await profileLocalDataSource.cacheProfile(profile);
      emit(state.copyWith(
        loading: false,
        profile: profile,
      ));
    } on UnauthorizedException catch (error) {
      await _handleUnauthorized(
        emit: emit,
        error: error,
        refreshToken: refreshToken,
      );
    } on TokenExpiredException catch (error) {
      await _handleUnauthorized(
        emit: emit,
        error: error,
        refreshToken: refreshToken,
      );
    } on ForbiddenException catch (error) {
      emit(state.copyWith(
        loading: false,
        error: ForbiddenFailure(message: error.message),
      ));
    } on NotFoundException catch (error) {
      emit(state.copyWith(
        loading: false,
        error: NotFoundFailure(
          code: error.code,
          message: 'Profile not found.',
        ),
      ));
    } on ServerException catch (error) {
      emit(state.copyWith(
        loading: false,
        error: ServerFailure(
          code: error.code,
          statusCode: error.statusCode,
          message: error.message,
        ),
      ));
    } catch (error) {
      emit(state.copyWith(
        loading: false,
        error: _mapToFailure(error),
      ));
    }
  }

  Future<void> _handleUnauthorized({
    required Emitter<ProfileState> emit,
    required AppException error,
    required String refreshToken,
  }) async {
    try {
      final user = await authRepository.refreshToken(
        refreshToken: refreshToken,
      );

      // Persist the new tokens so subsequent requests use them.
      await authLocalDataSource.markAuthenticatedSession(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );

      // Retry the profile request once.
      final ProfileModel profile = await profileRepository.getMyProfile();
      await profileLocalDataSource.cacheProfile(profile);
      emit(state.copyWith(
        loading: false,
        profile: profile,
      ));
    } catch (_) {
      await _logout();
      emit(state.copyWith(
        loading: false,
        error: UnauthorizedFailure(message: error.message),
        requiresLogin: true,
      ));
    }
  }

  Future<void> _logout() async {
    await authLocalDataSource.clearSession();
    await userLocalDataSource.clearUser();
  }

  Failure _mapToFailure(Object? error) {
    if (error is Failure) {
      return error;
    }
    if (error is AppException) {
      return ErrorMapper.mapExceptionToFailure(error);
    }
    return UnknownFailure(message: error?.toString());
  }

  bool _isNullOrEmpty(String? value) => value == null || value.isEmpty;
}
