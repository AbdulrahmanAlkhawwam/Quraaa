import 'package:dio/dio.dart';

import '../connectivity/connectivity_service.dart';
import '../connectivity/connection_status.dart';
import '../errors/exceptions.dart';

/// Dio interceptor that blocks outgoing HTTP requests when the device has no
/// network connection.
///
/// It checks [ConnectivityService.currentStatus] before every request. If the
/// device is offline it rejects the request immediately with a
/// [DioException.connectionError] whose underlying error is a
/// [NoInternetException]. This prevents any endpoint from being pushed while
/// there is no connectivity.
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._connectivityService);

  final ConnectivityService _connectivityService;

  static const String _noInternetMessage =
      'No internet connection. Please check your network and try again.';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final ConnectionStatus status = await _connectivityService.currentStatus();

    if (status == ConnectionStatus.connected) {
      return handler.next(options);
    }

    final NoInternetException exception = const NoInternetException(
      message: _noInternetMessage,
    );

    return handler.reject(
      DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: exception,
        message: _noInternetMessage,
      ),
    );
  }
}
