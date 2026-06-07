abstract class BaseRepository<T> {
  const BaseRepository();

  Future<T> getCached();
  Future<T> sync();
}
