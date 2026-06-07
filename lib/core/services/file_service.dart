abstract class FileService {
  Future<String> save(String path, List<int> bytes);
}
