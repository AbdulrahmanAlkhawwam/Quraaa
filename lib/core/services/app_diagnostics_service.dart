import 'package:client_information/client_information.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../config/env/env.dart';
import '../error_monitoring/app_logger.dart';

class AppDiagnosticsService {
  const AppDiagnosticsService(this._logger);

  final AppLogger _logger;

  Future<void> logStartupSnapshot() async {
    if (kReleaseMode) {
      return;
    }

    try {
      final ClientInformation clientInfo = await ClientInformation.fetch();
      final List<ConnectivityResult> transports =
          await Connectivity().checkConnectivity();
      final bool hasInternetAccess =
          await InternetConnection().hasInternetAccess;
      final String? latestVersion = Env.latestVersion;
      final bool hasNewVersion =
          latestVersion != null &&
          _isVersionOlder(clientInfo.applicationVersion, latestVersion);

      _logger.info(
        'Startup snapshot',
        source: 'AppDiagnosticsService',
        data: <String, Object?>{
          'app': clientInfo.applicationName,
          'version': clientInfo.applicationVersion,
          'buildNumber': clientInfo.applicationBuildCode,
          'baseUrl': Env.apiBaseUrl,
          'networkTransports': transports
              .map((ConnectivityResult result) => result.name)
              .toList(growable: false),
          'internetAccess': hasInternetAccess,
          'latestVersion': latestVersion ?? 'not set',
          'newVersionAvailable': hasNewVersion,
          'timezone': DateTime.now().timeZoneName,
        },
      );
    } catch (error, stackTrace) {
      _logger.warning(
        'Startup diagnostics skipped: $error',
        source: 'AppDiagnosticsService',
        data: <String, Object?>{
          'stackTrace': stackTrace.toString(),
        },
      );
    }
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
