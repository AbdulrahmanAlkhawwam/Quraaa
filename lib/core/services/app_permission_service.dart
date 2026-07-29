import '../constants/app_storage_keys.dart';
import 'location_permission_service.dart';
import 'notification_service.dart';
import 'storage_permission_service.dart';
import 'storage_service.dart';

abstract class AppPermissionService {
  Future<void> requestInitialPermissions();
}

class AppPermissionServiceImpl implements AppPermissionService {
  AppPermissionServiceImpl({
    required StorageService storageService,
    required NotificationService notificationService,
    required LocationPermissionService locationPermissionService,
    required StoragePermissionService storagePermissionService,
  }) : _storageService = storageService,
       _notificationService = notificationService,
       _locationPermissionService = locationPermissionService,
       _storagePermissionService = storagePermissionService;

  final StorageService _storageService;
  final NotificationService _notificationService;
  final LocationPermissionService _locationPermissionService;
  final StoragePermissionService _storagePermissionService;

  bool _requestInProgress = false;

  @override
  Future<void> requestInitialPermissions() async {
    if (_requestInProgress ||
        _storageService.getBool(AppStorageKeys.initialPermissionsRequested) ==
            true) {
      return;
    }

    _requestInProgress = true;
    try {
      await _requestSafely(_notificationService.requestPermission);
      await _requestSafely(_locationPermissionService.requestWhileInUse);
      await _requestSafely(() async {
        await _storagePermissionService.requestStorageAccess();
      });

      await _storageService.setBool(
        AppStorageKeys.initialPermissionsRequested,
        true,
      );
    } finally {
      _requestInProgress = false;
    }
  }

  Future<void> _requestSafely(Future<void> Function() request) async {
    try {
      await request();
    } catch (_) {
      // Unsupported or denied permissions must not block the home screen.
    }
  }
}
