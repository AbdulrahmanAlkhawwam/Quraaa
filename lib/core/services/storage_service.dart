abstract class StorageService {
  Future<void> write(String key, Object value);
  Future<Object?> read(String key);
}
