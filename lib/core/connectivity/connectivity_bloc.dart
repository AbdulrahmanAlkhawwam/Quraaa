import 'package:flutter_bloc/flutter_bloc.dart';

import 'connection_status.dart';
import 'connectivity_service.dart';

sealed class ConnectivityEvent {
  const ConnectivityEvent();
}

final class ConnectivityRequested extends ConnectivityEvent {
  const ConnectivityRequested();
}

sealed class ConnectivityState {
  const ConnectivityState();
}

final class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial();
}

final class ConnectivityUpdated extends ConnectivityState {
  const ConnectivityUpdated(this.status);

  final ConnectionStatus status;
}

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc(this._service) : super(const ConnectivityInitial()) {
    on<ConnectivityRequested>(_onRequested);
  }

  final ConnectivityService _service;

  Future<void> _onRequested(
    ConnectivityRequested event,
    Emitter<ConnectivityState> emit,
  ) async {
    emit(ConnectivityUpdated(await _service.currentStatus()));
  }
}
