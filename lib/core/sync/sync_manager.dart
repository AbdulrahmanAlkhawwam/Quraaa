import 'sync_queue.dart';
import 'sync_worker.dart';

class SyncManager {
  const SyncManager({
    required SyncQueue queue,
    required SyncWorker worker,
  })  : _queue = queue,
        _worker = worker;

  final SyncQueue _queue;
  final SyncWorker _worker;

  Future<void> process() async {
    await _queue.pending();
    await _worker.execute();
  }
}
