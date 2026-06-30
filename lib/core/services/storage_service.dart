abstract class StorageService {
  String? getString(String key);

  Future<bool> setString(String key, String value);

  int? getInt(String key);

  Future<bool> setInt(String key, int value);

  bool? getBool(String key);

  Future<bool> setBool(String key, bool value);

  List<String>? getStringList(String key);

  Future<bool> setStringList(String key, List<String> value);

  Future<bool> remove(String key);
  bool contains(String key);
  Future<bool> clearAll();
}
