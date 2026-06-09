import 'connection_status.dart';

abstract class ConnectivityService {
  Stream<ConnectionStatus> watchStatus();
  Future<ConnectionStatus> currentStatus();
}
