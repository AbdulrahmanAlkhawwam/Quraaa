import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_device_info_plus/flutter_device_info_plus.dart';

class DeviceInfoProvider {
  DeviceInfoProvider();

  DeviceSnapshot? _cachedSnapshot;

  Future<DeviceSnapshot> initialize() async {
    if (_cachedSnapshot != null) {
      return _cachedSnapshot!;
    }

    try {
      _cachedSnapshot = await _loadSnapshot();
    } catch (_) {
      _cachedSnapshot = DeviceSnapshot.unknown();
    }

    return _cachedSnapshot!;
  }

  DeviceSnapshot get snapshot {
    return _cachedSnapshot ?? DeviceSnapshot.unknown();
  }

  Future<DeviceSnapshot> _loadSnapshot() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final Locale locale = WidgetsBinding.instance.platformDispatcher.locale;
    final deviceInfo = FlutterDeviceInfoPlus();
    final deviceData = await deviceInfo.getDeviceInfo();

    if (kIsWeb) {
      return DeviceSnapshot(
        platform: 'web',
        deviceModel: deviceData.model.isNotEmpty
            ? deviceData.model
            : (deviceData.deviceName.isNotEmpty
                ? deviceData.deviceName
                : 'web'),
        manufacturer: deviceData.brand.isNotEmpty ? deviceData.brand : 'web',
        osVersion: deviceData.systemVersion.isNotEmpty
            ? deviceData.systemVersion
            : 'unknown',
        locale: locale.toLanguageTag(),
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        appName: packageInfo.appName,
        environment: packageInfo.packageName,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return DeviceSnapshot(
        platform: 'android',
        deviceModel: deviceData.model.isNotEmpty
            ? deviceData.model
            : deviceData.deviceName,
        manufacturer:
            deviceData.brand.isNotEmpty ? deviceData.brand : 'unknown',
        osVersion: deviceData.systemVersion.isNotEmpty
            ? deviceData.systemVersion
            : 'unknown',
        locale: locale.toLanguageTag(),
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        appName: packageInfo.appName,
        environment: packageInfo.packageName,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return DeviceSnapshot(
        platform: 'ios',
        deviceModel: deviceData.model.isNotEmpty
            ? deviceData.model
            : deviceData.deviceName,
        manufacturer: 'Apple',
        osVersion: deviceData.systemVersion.isNotEmpty
            ? deviceData.systemVersion
            : 'unknown',
        locale: locale.toLanguageTag(),
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        appName: packageInfo.appName,
        environment: packageInfo.packageName,
      );
    }

    return DeviceSnapshot(
      platform: defaultTargetPlatform.name,
      deviceModel: deviceData.model.isNotEmpty == true
          ? deviceData.model
          : deviceData.deviceName,
      manufacturer: deviceData.brand.isNotEmpty == true
          ? deviceData.brand
          : defaultTargetPlatform.name,
      osVersion: deviceData.systemVersion.isNotEmpty
          ? deviceData.systemVersion
          : 'unknown',
      locale: locale.toLanguageTag(),
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      appName: packageInfo.appName,
      environment: packageInfo.packageName,
    );
  }
}

class DeviceSnapshot {
  const DeviceSnapshot({
    required this.platform,
    required this.deviceModel,
    required this.manufacturer,
    required this.osVersion,
    required this.locale,
    required this.appVersion,
    required this.buildNumber,
    required this.appName,
    required this.environment,
  });

  const DeviceSnapshot.unknown()
      : platform = 'unknown',
        deviceModel = 'unknown',
        manufacturer = 'unknown',
        osVersion = 'unknown',
        locale = 'unknown',
        appVersion = 'unknown',
        buildNumber = 'unknown',
        appName = 'unknown',
        environment = 'unknown';

  final String platform;
  final String deviceModel;
  final String manufacturer;
  final String osVersion;
  final String locale;
  final String appVersion;
  final String buildNumber;
  final String appName;
  final String environment;
}
