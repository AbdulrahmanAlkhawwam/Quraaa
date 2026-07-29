abstract class StoragePermissionService {
  Future<bool> hasStorageAccess();

  Future<bool> requestStorageAccess();
}
