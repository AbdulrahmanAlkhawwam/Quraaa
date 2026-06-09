abstract class ConflictResolver<T> {
  T resolve({required T local, required T remote});
}
