import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/services/location_permission_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/datasources/auth_local_datasource.dart';

class AuthPermissionCubit extends Cubit<AuthPermissionState> {
  AuthPermissionCubit({
    required AuthLocalDataSource authJourney,
    required NotificationService notificationService,
    required LocationPermissionService locationPermissionService,
  })  : _authJourney = authJourney,
        _notificationService = notificationService,
        _locationPermissionService = locationPermissionService,
        super(const AuthPermissionState());

  final AuthLocalDataSource _authJourney;
  final NotificationService _notificationService;
  final LocationPermissionService _locationPermissionService;

  Future<void> requestNotificationPermission() async {
    emit(state.copyWith(status: AuthPermissionStatus.loading));
    await _authJourney.markNotificationPermissionSeen();
    try {
      await _notificationService.requestPermission();
    } catch (_) {
      // Permission plugins can fail on unsupported platforms; keep the flow moving.
    }
    await _navigateAfterNotification();
  }

  Future<void> skipNotificationPermission() async {
    emit(state.copyWith(status: AuthPermissionStatus.loading));
    await _authJourney.markNotificationPermissionSeen();
    await _navigateAfterNotification();
  }

  Future<void> requestLocationWhileInUse() async {
    await _handleLocationPermission(
      _locationPermissionService.requestWhileInUse,
    );
  }

  Future<void> requestLocationAlways() async {
    await _handleLocationPermission(_locationPermissionService.requestAlways);
  }

  Future<void> skipLocationPermission() async {
    emit(state.copyWith(status: AuthPermissionStatus.loading));
    await _authJourney.markLocationPermissionSeen();
    await _navigateAfterLocation();
  }

  Future<void> _handleLocationPermission(Future<void> Function() request) async {
    emit(state.copyWith(status: AuthPermissionStatus.loading));
    await _authJourney.markLocationPermissionSeen();
    try {
      await request();
    } catch (_) {
      // Permission plugins can fail on unsupported platforms; keep the flow moving.
    }
    await _navigateAfterLocation();
  }

  Future<void> _navigateAfterNotification() async {
    final bool locationSeen = await _authJourney.isLocationPermissionSeen();
    _emitNavigation(
      locationSeen ? RouteNames.home : RouteNames.locationPermission,
    );
  }

  Future<void> _navigateAfterLocation() async {
    final bool notificationSeen = await _authJourney
        .isNotificationPermissionSeen();
    _emitNavigation(
      notificationSeen ? RouteNames.home : RouteNames.notificationPermission,
    );
  }

  void _emitNavigation(String route) {
    emit(
      state.copyWith(
        status: AuthPermissionStatus.navigate,
        nextRoute: route,
        navigationSerial: state.navigationSerial + 1,
      ),
    );
  }
}

enum AuthPermissionStatus { initial, loading, navigate }

@immutable
class AuthPermissionState {
  const AuthPermissionState({
    this.status = AuthPermissionStatus.initial,
    this.nextRoute,
    this.navigationSerial = 0,
  });

  final AuthPermissionStatus status;
  final String? nextRoute;
  final int navigationSerial;

  bool get isLoading => status == AuthPermissionStatus.loading;

  AuthPermissionState copyWith({
    AuthPermissionStatus? status,
    String? nextRoute,
    int? navigationSerial,
  }) {
    return AuthPermissionState(
      status: status ?? this.status,
      nextRoute: nextRoute ?? this.nextRoute,
      navigationSerial: navigationSerial ?? this.navigationSerial,
    );
  }
}