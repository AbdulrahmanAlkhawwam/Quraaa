import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'connection_status.dart';
import 'connectivity_service.dart';

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl({InternetConnection? internetConnection})
      : _internetConnection = internetConnection ?? InternetConnection();

  final InternetConnection _internetConnection;

  @override
  Stream<ConnectionStatus> watchStatus() {
    return _internetConnection.onStatusChange.map(_mapStatus);
  }

  @override
  Future<ConnectionStatus> currentStatus() async {
    final bool hasInternetAccess = await _internetConnection.hasInternetAccess;
    return hasInternetAccess
        ? ConnectionStatus.connected
        : ConnectionStatus.disconnected;
  }

  ConnectionStatus _mapStatus(InternetStatus status) {
    return status == InternetStatus.connected
        ? ConnectionStatus.connected
        : ConnectionStatus.disconnected;
  }
}
