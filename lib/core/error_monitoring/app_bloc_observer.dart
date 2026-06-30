import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_logger.dart';

class AppBlocObserver extends BlocObserver {
  AppBlocObserver(this._logger);

  final AppLogger _logger;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    unawaited(
      _logger.error(
        error,
        stackTrace: stackTrace,
        source: bloc.runtimeType.toString(),
        message: 'Bloc error in ${bloc.runtimeType}',
      ),
    );
    super.onError(bloc, error, stackTrace);
  }
}
