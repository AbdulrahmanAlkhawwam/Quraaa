import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/env/env.dart';
import '../../core/di/injection_container.dart';
import '../../core/error_monitoring/device_info_provider.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_radius.dart';
import '../../shared/theme/app_spacing.dart';

/// A floating debug button that only appears in development mode.
///
/// Tapping it opens a bottom sheet showing:
/// - Cached SharedPreferences data
/// - Device information
/// - Connectivity / online status
///
/// Place this as the last child in a [Stack] so it renders on top of every
/// screen.
class DevDebugOverlay extends StatelessWidget {
  const DevDebugOverlay({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context) {
    if (!Env.isDev) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing16),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () => _showDebugSheet(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error500.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.bug_report, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDebugSheet(BuildContext context) {
    final BuildContext? navContext = navigatorKey?.currentContext;
    showModalBottomSheet(
      context: navContext ?? context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const _DebugInfoSheet(),
    );
  }
}

class _DebugInfoSheet extends StatefulWidget {
  const _DebugInfoSheet();

  @override
  State<_DebugInfoSheet> createState() => _DebugInfoSheetState();
}

class _DebugInfoSheetState extends State<_DebugInfoSheet> {
  Map<String, dynamic>? _cacheData;
  Map<String, String>? _deviceData;
  String? _connectivityStatus;
  bool? _hasInternet;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Cache
      final SharedPreferences prefs = sl<SharedPreferences>();
      final Set<String> keys = prefs.getKeys();
      final Map<String, dynamic> cache = <String, dynamic>{};
      for (final String key in keys) {
        cache[key] = prefs.get(key);
      }

      // Device
      final DeviceInfoProvider deviceInfo = sl<DeviceInfoProvider>();
      await deviceInfo.initialize();
      final DeviceSnapshot snapshot = deviceInfo.snapshot;
      final Map<String, String> device = <String, String>{
        'Platform': snapshot.platform,
        'Model': snapshot.deviceModel,
        'Manufacturer': snapshot.manufacturer,
        'OS Version': snapshot.osVersion,
        'Locale': snapshot.locale,
        'App Version': snapshot.appVersion,
        'Build Number': snapshot.buildNumber,
        'App Name': snapshot.appName,
        'Environment': snapshot.environment,
      };

      // Connectivity
      final List<ConnectivityResult> results = await Connectivity()
          .checkConnectivity();
      final String connectivityStatus =
          results.isEmpty ||
              results.every(
                (ConnectivityResult r) => r == ConnectivityResult.none,
              )
          ? 'Disconnected'
          : 'Connected (${results.map((ConnectivityResult r) => r.name).join(', ')})';
      final bool hasInternet = await InternetConnection().hasInternetAccess;

      if (!mounted) return;

      setState(() {
        _cacheData = cache;
        _deviceData = device;
        _connectivityStatus = connectivityStatus;
        _hasInternet = hasInternet;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.spacing16),
      padding: const EdgeInsets.all(AppSpacing.spacing20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.radius32),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.bug_report, color: AppColors.error500),
              const SizedBox(width: AppSpacing.spacing12),
              Expanded(
                child: Text(
                  'Dev Debug Info',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Divider(height: 24),
          Flexible(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildSectionTitle('Connectivity'),
                        _buildInfoRow(
                          'Status',
                          _connectivityStatus ?? 'Unknown',
                        ),
                        _buildInfoRow(
                          'Internet Access',
                          _hasInternet == true ? 'Yes' : 'No',
                        ),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Device'),
                        ..._deviceData!.entries.map(
                          (MapEntry<String, String> e) =>
                              _buildInfoRow(e.key, e.value),
                        ),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Cache (SharedPreferences)'),
                        if (_cacheData == null || _cacheData!.isEmpty)
                          const Text(
                            'No cached data',
                            style: TextStyle(color: AppColors.textSecondary),
                          )
                        else
                          ..._cacheData!.entries.map(
                            (MapEntry<String, dynamic> e) =>
                                _buildInfoRow(e.key, _formatValue(e.value)),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: AppColors.libraryGreen,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is List) return value.toString();
    return value.toString();
  }
}
