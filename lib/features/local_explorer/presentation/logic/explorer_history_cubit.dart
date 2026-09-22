import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/explorer_history_entry.dart';
import '../../domain/repositories/explorer_history_repository.dart';

class ExplorerHistoryState extends Equatable {
  const ExplorerHistoryState({
    this.entries = const <ExplorerHistoryEntry>[],
    this.loading = false,
    this.errorKey,
    this.errorSerial = 0,
  });

  final List<ExplorerHistoryEntry> entries;
  final bool loading;
  final String? errorKey;
  final int errorSerial;

  ExplorerHistoryState copyWith({
    List<ExplorerHistoryEntry>? entries,
    bool? loading,
    String? errorKey,
    bool clearError = false,
    int? errorSerial,
  }) {
    return ExplorerHistoryState(
      entries: entries ?? this.entries,
      loading: loading ?? this.loading,
      errorKey: clearError ? null : errorKey ?? this.errorKey,
      errorSerial: errorSerial ?? this.errorSerial,
    );
  }

  @override
  List<Object?> get props => <Object?>[entries, loading, errorKey, errorSerial];
}

class ExplorerHistoryCubit extends Cubit<ExplorerHistoryState> {
  ExplorerHistoryCubit(this._repository) : super(const ExplorerHistoryState());

  final ExplorerHistoryRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    final List<ExplorerHistoryEntry> entries = await _repository.loadHistory();
    emit(state.copyWith(entries: entries, loading: false, clearError: true));
  }

  Future<bool> prepareToOpen(ExplorerHistoryEntry entry) async {
    if (await _repository.fileExists(entry.path)) {
      return true;
    }

    await _repository.removeEntry(entry.path);
    final List<ExplorerHistoryEntry> entries = await _repository.loadHistory();
    emit(
      state.copyWith(
        entries: entries,
        errorKey: 'explorer_history.file_missing',
        errorSerial: state.errorSerial + 1,
      ),
    );
    return false;
  }
}
