import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/routes/route_names.dart';
import '../../shared/extensions/app_context.dart';
import '../di/injection_container.dart';
import 'connection_status.dart';
import 'connectivity_service.dart';

/// Redirects the user to the auth screen as soon as the device goes offline.
///
/// Use this to wrap routes that must not be visible without an internet
/// connection, such as registration and OTP verification.
class OfflineRouteGuard extends StatefulWidget {
  const OfflineRouteGuard({required this.child, super.key});

  final Widget child;

  @override
  State<OfflineRouteGuard> createState() => _OfflineRouteGuardState();
}

class _OfflineRouteGuardState extends State<OfflineRouteGuard> {
  StreamSubscription<ConnectionStatus>? _subscription;

  @override
  void initState() {
    super.initState();
    _checkCurrentStatus();
    _subscription = sl<ConnectivityService>()
        .watchStatus()
        .listen(_onStatusChanged);
  }

  void _checkCurrentStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final ConnectionStatus status =
          await sl<ConnectivityService>().currentStatus();
      if (status == ConnectionStatus.disconnected) {
        _goToAuth();
      }
    });
  }

  void _onStatusChanged(ConnectionStatus status) {
    if (status == ConnectionStatus.disconnected) {
      _goToAuth();
    }
  }

  void _goToAuth() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.goTo(RouteNames.auth);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
