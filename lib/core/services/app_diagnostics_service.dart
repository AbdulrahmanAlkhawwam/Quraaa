import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../config/env/env.dart';

class AppDiagnosticsService {
  const AppDiagnosticsService();

  Future<void> logStartupSnapshot() async {
    if (!kDebugMode) {
      return;
    }

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final List<ConnectivityResult> transports =
        await Connectivity().checkConnectivity();
    final bool hasInternetAccess =
        await InternetConnection().hasInternetAccess;
    final Locale deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final String localeTag = deviceLocale.countryCode == null
        ? deviceLocale.languageCode
        : '${deviceLocale.languageCode}_${deviceLocale.countryCode}';
    final Map<String, Object?> deviceData = await _deviceInfo();
    final String? latestVersion = Env.latestVersion;
    final bool hasNewVersion =
        latestVersion != null && _isVersionOlder(packageInfo.version, latestVersion);

    debugPrint('--- App Diagnostics ---');
    debugPrint('App: ${packageInfo.appName}');
    debugPrint('Package version: ${packageInfo.version}');
    debugPrint('Build number: ${packageInfo.buildNumber}');
    debugPrint('Base URL: ${Env.apiBaseUrl}');
    debugPrint('Locale: $localeTag');
    debugPrint('Timezone: ${DateTime.now().timeZoneName}');
    debugPrint('Network transports: $transports');
    debugPrint('Internet access: $hasInternetAccess');
    debugPrint('Latest version configured: ${latestVersion ?? 'not set'}');
    debugPrint('New version available: $hasNewVersion');
    debugPrint('Device data: $deviceData');
    debugPrint('-----------------------');
  }

  Future<Map<String, Object?>> _deviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    if (kIsWeb) {
      return <String, Object?>{
        'platform': 'web',
        'browserLocale': WidgetsBinding.instance.platformDispatcher.locale
            .toLanguageTag(),
      };
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      return <String, Object?>{
        'platform': 'android',
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'device': androidInfo.device,
        'version': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
      };
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      return <String, Object?>{
        'platform': 'ios',
        'model': iosInfo.model,
        'systemName': iosInfo.systemName,
        'systemVersion': iosInfo.systemVersion,
        'localizedModel': iosInfo.localizedModel,
      };
    }

    return <String, Object?>{
      'platform': defaultTargetPlatform.name,
      'locale': WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag(),
    };
  }

  bool _isVersionOlder(String currentVersion, String latestVersion) {
    final List<int> currentParts = _parseVersion(currentVersion);
    final List<int> latestParts = _parseVersion(latestVersion);

    for (int index = 0; index < 3; index++) {
      final int current = index < currentParts.length ? currentParts[index] : 0;
      final int latest = index < latestParts.length ? latestParts[index] : 0;
      if (current != latest) {
        return current < latest;
      }
    }

    return false;
  }

  List<int> _parseVersion(String version) {
    return version
        .split('.')
        .map((String part) => int.tryParse(part) ?? 0)
        .toList(growable: false);
  }
}
