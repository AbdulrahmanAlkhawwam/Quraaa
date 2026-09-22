import 'dart:typed_data';

/// Random-access PDF bytes exposed to the reader without writing a clear-text
/// PDF to disk. Implementations may serve ranges from the network or decrypt
/// them from the private application cache.
abstract class PurchaseBookSession {
  int get fileSize;

  String get sourceName;

  bool get isOffline;

  Future<int> read(Uint8List buffer, int position, int size);

  Future<void> cacheForOffline();

  Future<void> dispose();
}
