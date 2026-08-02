import 'package:equatable/equatable.dart';

class ExplorerHistoryEntry extends Equatable {
  const ExplorerHistoryEntry({
    required this.name,
    required this.path,
    required this.directoryName,
    required this.openedAt,
  });

  final String name;
  final String path;
  final String directoryName;
  final DateTime openedAt;

  @override
  List<Object?> get props => <Object?>[name, path, directoryName, openedAt];
}
