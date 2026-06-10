import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/local_directory_snapshot.dart';
import '../../domain/repositories/local_file_repository.dart';
import '../../domain/use_cases/load_local_directory_use_case.dart';

sealed class LocalExplorerEvent {
  const LocalExplorerEvent();
}

final class LocalExplorerStarted extends LocalExplorerEvent {
  const LocalExplorerStarted({this.path});

  final String? path;
}

final class LocalExplorerDirectoryOpened extends LocalExplorerEvent {
  const LocalExplorerDirectoryOpened(this.path);

  final String path;
}

final class LocalExplorerBreadcrumbSelected extends LocalExplorerEvent {
  const LocalExplorerBreadcrumbSelected(this.path);

  final String path;
}

final class LocalExplorerParentRequested extends LocalExplorerEvent {
  const LocalExplorerParentRequested();
}

final class LocalExplorerRefreshRequested extends LocalExplorerEvent {
  const LocalExplorerRefreshRequested();
}

final class LocalExplorerAccessRequested extends LocalExplorerEvent {
  const LocalExplorerAccessRequested();
}

sealed class LocalExplorerState {
  const LocalExplorerState();
}

final class LocalExplorerInitial extends LocalExplorerState {
  const LocalExplorerInitial();
}

final class LocalExplorerLoading extends LocalExplorerState {
  const LocalExplorerLoading({this.previous});

  final LocalDirectorySnapshot? previous;
}

final class LocalExplorerLoaded extends LocalExplorerState {
  const LocalExplorerLoaded(this.snapshot);

  final LocalDirectorySnapshot snapshot;
}

final class LocalExplorerAccessRequired extends LocalExplorerState {
  const LocalExplorerAccessRequired();
}

final class LocalExplorerFailure extends LocalExplorerState {
  const LocalExplorerFailure(this.message, {this.previous});

  final String message;
  final LocalDirectorySnapshot? previous;
}

class LocalExplorerBloc extends Bloc<LocalExplorerEvent, LocalExplorerState> {
  LocalExplorerBloc({
    required LoadLocalDirectoryUseCase loadDirectory,
    required LocalFileRepository repository,
  })  : _loadDirectory = loadDirectory,
        _repository = repository,
        super(const LocalExplorerInitial()) {
    on<LocalExplorerStarted>(_onStarted);
    on<LocalExplorerDirectoryOpened>(_onDirectoryOpened);
    on<LocalExplorerBreadcrumbSelected>(_onBreadcrumbSelected);
    on<LocalExplorerParentRequested>(_onParentRequested);
    on<LocalExplorerRefreshRequested>(_onRefreshRequested);
    on<LocalExplorerAccessRequested>(_onAccessRequested);
  }

  final LoadLocalDirectoryUseCase _loadDirectory;
  final LocalFileRepository _repository;

  LocalDirectorySnapshot? _snapshot;

  Future<void> _onStarted(
    LocalExplorerStarted event,
    Emitter<LocalExplorerState> emit,
  ) {
    return _open(path: event.path, emit: emit);
  }

  Future<void> _onDirectoryOpened(
    LocalExplorerDirectoryOpened event,
    Emitter<LocalExplorerState> emit,
  ) {
    return _open(path: event.path, emit: emit);
  }

  Future<void> _onBreadcrumbSelected(
    LocalExplorerBreadcrumbSelected event,
    Emitter<LocalExplorerState> emit,
  ) {
    return _open(path: event.path, emit: emit);
  }

  Future<void> _onParentRequested(
    LocalExplorerParentRequested event,
    Emitter<LocalExplorerState> emit,
  ) async {
    final LocalDirectorySnapshot? snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }

    final String? parentPath = _repository.parentOf(snapshot.currentPath);
    if (parentPath == null) {
      return;
    }

    await _open(path: parentPath, emit: emit);
  }

  Future<void> _onRefreshRequested(
    LocalExplorerRefreshRequested event,
    Emitter<LocalExplorerState> emit,
  ) {
    return _open(path: _snapshot?.currentPath, emit: emit);
  }

  Future<void> _onAccessRequested(
    LocalExplorerAccessRequested event,
    Emitter<LocalExplorerState> emit,
  ) async {
    emit(LocalExplorerLoading(previous: _snapshot));
    final bool granted = await _repository.requestStorageAccess();
    if (!granted) {
      emit(const LocalExplorerAccessRequired());
      return;
    }

    await _open(path: _snapshot?.currentPath, emit: emit);
  }

  Future<void> _open({
    required String? path,
    required Emitter<LocalExplorerState> emit,
  }) async {
    emit(LocalExplorerLoading(previous: _snapshot));

    try {
      final LocalDirectorySnapshot snapshot = await _loadDirectory(
        LoadLocalDirectoryParams(path: path),
      );
      _snapshot = snapshot;
      emit(LocalExplorerLoaded(snapshot));
    } on FileAccessDeniedException {
      emit(const LocalExplorerAccessRequired());
    } on AppException catch (error) {
      emit(LocalExplorerFailure(error.message, previous: _snapshot));
    } on UnsupportedError catch (error) {
      emit(LocalExplorerFailure(error.message ?? '$error', previous: _snapshot));
    } catch (error) {
      emit(LocalExplorerFailure('$error', previous: _snapshot));
    }
  }
}
