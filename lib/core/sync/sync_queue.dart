import 'pending_operation.dart';

abstract class SyncQueue {
  Future<void> enqueue(PendingOperation operation);
  Future<List<PendingOperation>> pending();
}
