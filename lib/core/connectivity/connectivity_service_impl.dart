    import 'package:connectivity_plus/connectivity_plus.dart';

import 'connection_status.dart';
import 'connectivity_service.dart';

class ConnectivityServiceImpl implements ConnectivityService {
  @override
  Stream<ConnectionStatus> watchStatus() {
    return Connectivity()
        .onConnectivityChanged
        .map((List<ConnectivityResult> results) => _mapResults(results));
  }

  @override
  Future<ConnectionStatus> currentStatus() async {
    final List<ConnectivityResult> results =
        await Connectivity().checkConnectivity();
    return _mapResults(results);
  }

  ConnectionStatus _mapResults(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        results.every((ConnectivityResult r) => r == ConnectivityResult.none)) {
      return ConnectionStatus.disconnected;
    }
    return ConnectionStatus.connected;
  }
}
