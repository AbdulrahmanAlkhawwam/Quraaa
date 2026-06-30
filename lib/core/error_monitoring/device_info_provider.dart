import 'package:client_information/client_information.dart';
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
    final ClientInformation clientInfo = await ClientInformation.fetch();
    final Locale locale = WidgetsBinding.instance.platformDispatcher.locale;
    final deviceInfo = FlutterDeviceInfoPlus();
    final deviceData = await deviceInfo.getDeviceInfo();

    if (kIsWeb) {
      return DeviceSnapshot(
        platform: 'web',
        deviceModel: deviceData.model?.isNotEmpty == true
            ? deviceData.model!
            : (deviceData.deviceName.isNotEmpty
                ? deviceData.deviceName
                : (clientInfo.softwareName.isNotEmpty
                    ? clientInfo.softwareName
                    : 'web')),
        manufacturer: deviceData.brand?.isNotEmpty == true
            ? deviceData.brand!
            : (clientInfo.softwareName.isNotEmpty
                ? clientInfo.softwareName
                : 'web'),
        osVersion: deviceData.systemVersion.isNotEmpty
            ? deviceData.systemVersion
            : (clientInfo.osVersion.isNotEmpty
                ? '${clientInfo.osName} ${clientInfo.osVersion}'
                : 'unknown'),
        locale: locale.toLanguageTag(),
        appVersion: clientInfo.applicationVersion,
        buildNumber: clientInfo.applicationBuildCode,
        appName: clientInfo.applicationName,
        environment: clientInfo.applicationId ?? 'web',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return DeviceSnapshot(
        platform: 'android',
        deviceModel: deviceData.model?.isNotEmpty == true
            ? deviceData.model!
            : deviceData.deviceName,
        manufacturer: deviceData.brand?.isNotEmpty == true
            ? deviceData.brand!
            : 'unknown',
        osVersion: deviceData.systemVersion.isNotEmpty
            ? deviceData.systemVersion
            : (clientInfo.osVersion.isNotEmpty
                ? clientInfo.osVersion
                : 'unknown'),
        locale: locale.toLanguageTag(),
        appVersion: clientInfo.applicationVersion,
        buildNumber: clientInfo.applicationBuildCode,
        appName: clientInfo.applicationName,
        environment: clientInfo.applicationId ?? 'unknown',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return DeviceSnapshot(
        platform: 'ios',
        deviceModel: deviceData.model?.isNotEmpty == true
            ? deviceData.model!
            : deviceData.deviceName,
        manufacturer: 'Apple',
        osVersion: deviceData.systemVersion.isNotEmpty
            ? deviceData.systemVersion
            : (clientInfo.osVersion.isNotEmpty
                ? clientInfo.osVersion
                : 'unknown'),
        locale: locale.toLanguageTag(),
        appVersion: clientInfo.applicationVersion,
        buildNumber: clientInfo.applicationBuildCode,
        appName: clientInfo.applicationName,
        environment: clientInfo.applicationId ?? 'unknown',
      );
    }

    return DeviceSnapshot(
      platform: defaultTargetPlatform.name,
      deviceModel: deviceData.model?.isNotEmpty == true
          ? deviceData.model!
          : deviceData.deviceName,
      manufacturer: deviceData.brand?.isNotEmpty == true
          ? deviceData.brand!
          : defaultTargetPlatform.name,
      osVersion: deviceData.systemVersion.isNotEmpty
          ? deviceData.systemVersion
          : 'unknown',
      locale: locale.toLanguageTag(),
      appVersion: clientInfo.applicationVersion,
      buildNumber: clientInfo.applicationBuildCode,
      appName: clientInfo.applicationName,
      environment: clientInfo.applicationId ?? 'unknown',
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
