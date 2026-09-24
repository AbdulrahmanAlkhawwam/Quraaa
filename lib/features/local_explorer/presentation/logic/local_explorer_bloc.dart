import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/local_directory_snapshot.dart';
import '../../domain/use_cases/get_local_directory_parent_use_case.dart';
import '../../domain/use_cases/load_local_directory_use_case.dart';
import '../../domain/use_cases/request_local_storage_access_use_case.dart';

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
    required this._loadDirectory,
    required this._getParentDirectory,
    required this._requestStorageAccess,
  }) : super(const LocalExplorerInitial()) {
    on<LocalExplorerStarted>(_onStarted);
    on<LocalExplorerDirectoryOpened>(_onDirectoryOpened);
    on<LocalExplorerBreadcrumbSelected>(_onBreadcrumbSelected);
    on<LocalExplorerParentRequested>(_onParentRequested);
    on<LocalExplorerRefreshRequested>(_onRefreshRequested);
    on<LocalExplorerAccessRequested>(_onAccessRequested);
  }

  final LoadLocalDirectoryUseCase _loadDirectory;
  final GetLocalDirectoryParentUseCase _getParentDirectory;
  final RequestLocalStorageAccessUseCase _requestStorageAccess;

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

    final Either<Failure, String?> result = _getParentDirectory(
      GetLocalDirectoryParentParams(path: snapshot.currentPath),
    );

    await result.fold(
      (Failure failure) async {
        emit(LocalExplorerFailure(failure.message, previous: _snapshot));
      },
      (String? parentPath) async {
        if (parentPath == null) {
          return;
        }

        await _open(path: parentPath, emit: emit);
      },
    );
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
    final Either<Failure, bool> result = await _requestStorageAccess();

    await result.fold(
      (Failure failure) async {
        emit(LocalExplorerFailure(failure.message, previous: _snapshot));
      },
      (bool granted) async {
        if (!granted) {
          emit(const LocalExplorerAccessRequired());
          return;
        }

        await _open(path: _snapshot?.currentPath, emit: emit);
      },
    );
  }

  Future<void> _open({
    required String? path,
    required Emitter<LocalExplorerState> emit,
  }) async {
    emit(LocalExplorerLoading(previous: _snapshot));

    final Either<Failure, LocalDirectorySnapshot> result = await _loadDirectory(
      LoadLocalDirectoryParams(path: path),
    );

    result.fold(
      (Failure failure) {
        if (failure is FileAccessDeniedFailure) {
          emit(const LocalExplorerAccessRequired());
        } else {
          emit(LocalExplorerFailure(failure.message, previous: _snapshot));
        }
      },
      (LocalDirectorySnapshot snapshot) {
        _snapshot = snapshot;
        emit(LocalExplorerLoaded(snapshot));
      },
    );
  }
}
