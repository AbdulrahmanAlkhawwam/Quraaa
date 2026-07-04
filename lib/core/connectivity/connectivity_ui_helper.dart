import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/shared.dart';
import '../di/injection_container.dart';
import '../errors/failures.dart';
import 'connection_status.dart';
import 'connectivity_service.dart';

/// Checks whether the device is currently online.
///
/// If offline, shows a SnackBar whose content is resolved through
/// [ErrorMessageResolver]: raw technical details in debug builds and a
/// localized user-friendly message in release builds. Callers should abort any
/// network request when this returns `false`.
Future<bool> ensureOnline(BuildContext context) async {
  final ConnectionStatus status = await sl<ConnectivityService>().currentStatus();
  if (status == ConnectionStatus.connected) {
    return true;
  }

  if (context.mounted) {
    context.showResolvedErrorSnackBar(const NoInternetFailure());
  }
  return false;
}
