import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      final WebBrowserInfo browserInfo = await deviceInfo.webBrowserInfo;
      return DeviceSnapshot(
        platform: 'web',
        deviceModel: browserInfo.browserName.toString(),
        manufacturer: browserInfo.vendor ?? 'web',
        osVersion: browserInfo.userAgent ?? 'unknown',
        locale: locale.toLanguageTag(),
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        appName: packageInfo.appName,
        environment: packageInfo.packageName,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return DeviceSnapshot(
        platform: 'android',
        deviceModel: androidInfo.model,
        manufacturer: androidInfo.manufacturer.isNotEmpty
            ? androidInfo.manufacturer
            : androidInfo.brand,
        osVersion: androidInfo.version.release,
        locale: locale.toLanguageTag(),
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        appName: packageInfo.appName,
        environment: packageInfo.packageName,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return DeviceSnapshot(
        platform: 'ios',
        deviceModel: iosInfo.model,
        manufacturer: 'Apple',
        osVersion: iosInfo.systemVersion,
        locale: locale.toLanguageTag(),
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        appName: packageInfo.appName,
        environment: packageInfo.packageName,
      );
    }

    return DeviceSnapshot(
      platform: defaultTargetPlatform.name,
      deviceModel: defaultTargetPlatform.name,
      manufacturer: defaultTargetPlatform.name,
      osVersion: 'unknown',
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
