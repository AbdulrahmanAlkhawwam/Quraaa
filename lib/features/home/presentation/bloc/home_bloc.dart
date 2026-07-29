import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../../core/architecture/use_case.dart';
import '../../../../core/services/app_permission_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../account/account.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required LoadAccountUserSnapshotUseCase loadUserSnapshot,
    required NotificationService notificationService,
    required AppPermissionService appPermissionService,
  }) : _loadUserSnapshot = loadUserSnapshot,
       _notificationService = notificationService,
       _appPermissionService = appPermissionService,
       super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomePermissionsRequested>(_onPermissionsRequested);
    on<HomeNotificationReceived>(_onNotificationReceived);
  }

  final LoadAccountUserSnapshotUseCase _loadUserSnapshot;
  final NotificationService _notificationService;
  final AppPermissionService _appPermissionService;
  StreamSubscription<RemoteMessage>? _notificationSubscription;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    unawaited(_startNotifications());
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));

    try {
      final AccountUserSnapshot userSnapshot = await _loadUserSnapshot(
        const NoParams(),
      );
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          userSnapshot: userSnapshot,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _startNotifications() async {
    try {
      await _notificationService.initialize(shouldRequestPermission: false);
      await _notificationSubscription?.cancel();
      _notificationSubscription = _notificationService.foregroundMessages
          .listen(
            (RemoteMessage message) => add(HomeNotificationReceived(message)),
          );
    } catch (_) {
      // Notification providers may be unavailable in local/dev builds.
    }
  }

  Future<void> _onPermissionsRequested(
    HomePermissionsRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _appPermissionService.requestInitialPermissions();
  }

  void _onNotificationReceived(
    HomeNotificationReceived event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        notificationSerial: state.notificationSerial + 1,
        notificationTitle: event.message.notification?.title,
        notificationBody: event.message.notification?.body ?? '',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _notificationSubscription?.cancel();
    return super.close();
  }
}
