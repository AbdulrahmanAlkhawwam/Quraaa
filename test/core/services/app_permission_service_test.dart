import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/app_storage_keys.dart';
import 'package:quraaa/core/services/app_permission_service.dart';
import 'package:quraaa/core/services/location_permission_service.dart';
import 'package:quraaa/core/services/notification_service.dart';
import 'package:quraaa/core/services/storage_permission_service.dart';
import 'package:quraaa/core/services/storage_service.dart';

class _MockStorageService extends Mock implements StorageService {}

class _MockNotificationService extends Mock implements NotificationService {}

class _MockLocationPermissionService extends Mock
    implements LocationPermissionService {}

class _MockStoragePermissionService extends Mock
    implements StoragePermissionService {}

void main() {
  late _MockStorageService storageService;
  late _MockNotificationService notificationService;
  late _MockLocationPermissionService locationPermissionService;
  late _MockStoragePermissionService storagePermissionService;

  setUp(() {
    storageService = _MockStorageService();
    notificationService = _MockNotificationService();
    locationPermissionService = _MockLocationPermissionService();
    storagePermissionService = _MockStoragePermissionService();
  });

  test('requests notification, location, then storage permission', () async {
    final List<String> requestOrder = <String>[];
    when(
      () => storageService.getBool(AppStorageKeys.initialPermissionsRequested),
    ).thenReturn(false);
    when(() => notificationService.requestPermission()).thenAnswer((_) async {
      requestOrder.add('notification');
    });
    when(() => locationPermissionService.requestWhileInUse()).thenAnswer((
      _,
    ) async {
      requestOrder.add('location');
    });
    when(() => storagePermissionService.requestStorageAccess()).thenAnswer((
      _,
    ) async {
      requestOrder.add('storage');
      return true;
    });
    when(
      () => storageService.setBool(
        AppStorageKeys.initialPermissionsRequested,
        true,
      ),
    ).thenAnswer((_) async => true);

    await _buildService(
      storageService,
      notificationService,
      locationPermissionService,
      storagePermissionService,
    ).requestInitialPermissions();

    expect(requestOrder, <String>['notification', 'location', 'storage']);
    verify(
      () => storageService.setBool(
        AppStorageKeys.initialPermissionsRequested,
        true,
      ),
    ).called(1);
  });

  test('does not request permissions after the bundle was attempted', () async {
    when(
      () => storageService.getBool(AppStorageKeys.initialPermissionsRequested),
    ).thenReturn(true);

    await _buildService(
      storageService,
      notificationService,
      locationPermissionService,
      storagePermissionService,
    ).requestInitialPermissions();

    verifyNever(() => notificationService.requestPermission());
    verifyNever(() => locationPermissionService.requestWhileInUse());
    verifyNever(() => storagePermissionService.requestStorageAccess());
    verifyNever(
      () => storageService.setBool(
        AppStorageKeys.initialPermissionsRequested,
        true,
      ),
    );
  });

  test('continues when a platform permission request throws', () async {
    when(
      () => storageService.getBool(AppStorageKeys.initialPermissionsRequested),
    ).thenReturn(false);
    when(
      () => notificationService.requestPermission(),
    ).thenThrow(StateError('notification unavailable'));
    when(
      () => locationPermissionService.requestWhileInUse(),
    ).thenThrow(StateError('location unavailable'));
    when(
      () => storagePermissionService.requestStorageAccess(),
    ).thenThrow(StateError('storage unavailable'));
    when(
      () => storageService.setBool(
        AppStorageKeys.initialPermissionsRequested,
        true,
      ),
    ).thenAnswer((_) async => true);

    await _buildService(
      storageService,
      notificationService,
      locationPermissionService,
      storagePermissionService,
    ).requestInitialPermissions();

    verify(() => notificationService.requestPermission()).called(1);
    verify(() => locationPermissionService.requestWhileInUse()).called(1);
    verify(() => storagePermissionService.requestStorageAccess()).called(1);
    verify(
      () => storageService.setBool(
        AppStorageKeys.initialPermissionsRequested,
        true,
      ),
    ).called(1);
  });
}

AppPermissionService _buildService(
  StorageService storageService,
  NotificationService notificationService,
  LocationPermissionService locationPermissionService,
  StoragePermissionService storagePermissionService,
) {
  return AppPermissionServiceImpl(
    storageService: storageService,
    notificationService: notificationService,
    locationPermissionService: locationPermissionService,
    storagePermissionService: storagePermissionService,
  );
}
