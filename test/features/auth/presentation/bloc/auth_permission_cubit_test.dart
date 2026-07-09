import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/config/routes/route_names.dart';
import 'package:quraaa/core/services/location_permission_service.dart';
import 'package:quraaa/core/services/notification_service.dart';
import 'package:quraaa/features/auth/presentation/bloc/auth_permission_cubit.dart';

import '../../../../mocks/mock_classes.dart';

class MockNotificationService extends Mock implements NotificationService {}

class MockLocationPermissionService extends Mock
    implements LocationPermissionService {}

void main() {
  late MockAuthLocalDataSource authJourney;
  late MockNotificationService notificationService;
  late MockLocationPermissionService locationPermissionService;
  late AuthPermissionCubit cubit;

  setUp(() {
    authJourney = MockAuthLocalDataSource();
    notificationService = MockNotificationService();
    locationPermissionService = MockLocationPermissionService();
    cubit = AuthPermissionCubit(
      authJourney: authJourney,
      notificationService: notificationService,
      locationPermissionService: locationPermissionService,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('requestNotificationPermission marks seen and navigates to location',
      () async {
    when(() => authJourney.markNotificationPermissionSeen())
        .thenAnswer((_) async {});
    when(() => notificationService.requestPermission())
        .thenAnswer((_) async {});
    when(() => authJourney.isLocationPermissionSeen())
        .thenAnswer((_) async => false);

    await cubit.requestNotificationPermission();

    expect(cubit.state.status, AuthPermissionStatus.navigate);
    expect(cubit.state.nextRoute, RouteNames.locationPermission);
    verify(() => authJourney.markNotificationPermissionSeen()).called(1);
    verify(() => notificationService.requestPermission()).called(1);
  });

  test('skipNotificationPermission navigates home when location was seen',
      () async {
    when(() => authJourney.markNotificationPermissionSeen())
        .thenAnswer((_) async {});
    when(() => authJourney.isLocationPermissionSeen())
        .thenAnswer((_) async => true);

    await cubit.skipNotificationPermission();

    expect(cubit.state.nextRoute, RouteNames.home);
    verifyNever(() => notificationService.requestPermission());
  });

  test('requestLocationAlways marks seen and navigates to notification',
      () async {
    when(() => authJourney.markLocationPermissionSeen())
        .thenAnswer((_) async {});
    when(() => locationPermissionService.requestAlways())
        .thenAnswer((_) async {});
    when(() => authJourney.isNotificationPermissionSeen())
        .thenAnswer((_) async => false);

    await cubit.requestLocationAlways();

    expect(cubit.state.nextRoute, RouteNames.notificationPermission);
    verify(() => authJourney.markLocationPermissionSeen()).called(1);
    verify(() => locationPermissionService.requestAlways()).called(1);
  });
}