abstract class SyncableEntity {
  String get id;
  DateTime get updatedAt;
  bool get isDirty;
}
