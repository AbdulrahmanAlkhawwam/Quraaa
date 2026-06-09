class PendingOperation {
  const PendingOperation({
    required this.id,
    required this.entityId,
    required this.operation,
    required this.createdAt,
  });

  final String id;
  final String entityId;
  final String operation;
  final DateTime createdAt;
}
