import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/connectivity/connection_status.dart';
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/repositories/auth_session_repository.dart';
import '../../../auth/domain/use_cases/refresh_session_use_case.dart';
import '../../domain/entities/profile.dart';
import '../../domain/use_cases/get_cached_profile_use_case.dart';
import '../../domain/use_cases/get_my_profile_use_case.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC that loads the authenticated user's profile from the backend and keeps
/// the latest successful response cached for offline use.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required this._getMyProfile,
    required this._getCachedProfile,
    required this._refreshSession,
    required this._authSession,
    required this._connectivityService,
  }) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileCachedLoadRequested>(_onCachedLoadRequested);
    on<ProfileReplaced>(
      (ProfileReplaced event, Emitter<ProfileState> emit) =>
          emit(state.copyWith(profile: event.profile, clearError: true)),
    );
  }

  final GetMyProfileUseCase _getMyProfile;
  final GetCachedProfileUseCase _getCachedProfile;
  final RefreshSessionUseCase _refreshSession;
  final AuthSessionRepository _authSession;
  final ConnectivityService _connectivityService;

  Future<void> _onCachedLoadRequested(
    ProfileCachedLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    final Either<Failure, Profile?> result = await _getCachedProfile();
    emit(
      result.fold(
        (Failure failure) => state.copyWith(loading: false, error: failure),
        (Profile? profile) => state.copyWith(loading: false, profile: profile),
      ),
    );
  }

  /// Loads the user's profile when the device is online and the user is
  /// authenticated. Falls back to the cached profile when offline.
  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));

    // Missing tokens mean the user is not authenticated; stay idle.
    if (!await _authSession.hasStoredTokens()) {
      emit(state.copyWith(loading: false));
      return;
    }

    final ConnectionStatus connectionStatus = await _connectivityService
        .currentStatus();

    if (connectionStatus == ConnectionStatus.disconnected) {
      await _loadCachedProfile(emit);
      return;
    }

    await _fetchProfileWithRefreshRetry(emit);
  }

  Future<void> _loadCachedProfile(Emitter<ProfileState> emit) async {
    final Either<Failure, Profile?> result = await _getCachedProfile();
    emit(
      result.fold(
        (_) => state.copyWith(loading: false, error: const NoInternetFailure()),
        (Profile? profile) => state.copyWith(loading: false, profile: profile),
      ),
    );
  }

  Future<void> _fetchProfileWithRefreshRetry(Emitter<ProfileState> emit) async {
    final Either<Failure, Profile> result = await _getMyProfile();
    await result.fold((Failure failure) async {
      if (failure is UnauthorizedFailure || failure is TokenExpiredFailure) {
        await _handleUnauthorized(emit, failure);
        return;
      }
      emit(state.copyWith(loading: false, error: failure));
    }, (Profile profile) async {
      emit(state.copyWith(loading: false, profile: profile));
    });
  }

  Future<void> _handleUnauthorized(
    Emitter<ProfileState> emit,
    Failure original,
  ) async {
    // The global auth interceptor already attempted a refresh. If it cleared
    // the session, do not send a second refresh request with the old token.
    if (!await _authSession.isAuthenticatedSession()) {
      _emitRequiresLogin(emit, original.message);
      return;
    }

    // refreshSession persists the rotated tokens itself.
    final Either<Failure, String> refreshed = await _refreshSession();
    final Failure? refreshFailure = refreshed.getLeft().toNullable();
    if (refreshFailure != null) {
      await _authSession.signOutLocally();
      _emitRequiresLogin(emit, refreshFailure.message);
      return;
    }

    // Retry the profile request once; any failure now ends the session.
    final Either<Failure, Profile> retry = await _getMyProfile();
    final Profile? profile = retry.toNullable();
    if (profile == null) {
      await _authSession.signOutLocally();
      _emitRequiresLogin(emit, original.message);
      return;
    }
    emit(state.copyWith(loading: false, profile: profile));
  }

  void _emitRequiresLogin(Emitter<ProfileState> emit, String message) {
    emit(
      state.copyWith(
        loading: false,
        error: UnauthorizedFailure(message: message),
        requiresLogin: true,
      ),
    );
  }
}
