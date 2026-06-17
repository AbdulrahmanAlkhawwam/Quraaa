import 'dart:convert';

enum ErrorSeverity { debug, info, warning, error, fatal }

class ErrorReport {
  const ErrorReport({
    required this.severity,
    required this.exceptionType,
    required this.exceptionMessage,
    required this.stackTrace,
    required this.timestamp,
    this.userId,
    this.userName,
    this.userEmail,
    this.currentRoute,
    this.previousRoute,
    this.navigationHistory = const <String>[],
    this.lastUserAction,
    this.apiMethod,
    this.apiUrl,
    this.apiStatusCode,
    this.apiDuration,
    this.apiRequestBody,
    this.apiResponseBody,
    this.deviceModel,
    this.deviceManufacturer,
    this.deviceOsVersion,
    this.locale,
    this.appVersion,
    this.buildNumber,
    this.environment,
    this.language,
    this.subscriptionStatus,
    this.source,
  });

  final ErrorSeverity severity;
  final String exceptionType;
  final String exceptionMessage;
  final String stackTrace;
  final DateTime timestamp;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? currentRoute;
  final String? previousRoute;
  final List<String> navigationHistory;
  final String? lastUserAction;
  final String? apiMethod;
  final String? apiUrl;
  final int? apiStatusCode;
  final Duration? apiDuration;
  final String? apiRequestBody;
  final String? apiResponseBody;
  final String? deviceModel;
  final String? deviceManufacturer;
  final String? deviceOsVersion;
  final String? locale;
  final String? appVersion;
  final String? buildNumber;
  final String? environment;
  final String? language;
  final String? subscriptionStatus;
  final String? source;

  String get severityLabel => switch (severity) {
        ErrorSeverity.debug => 'DEBUG',
        ErrorSeverity.info => 'INFO',
        ErrorSeverity.warning => 'WARNING',
        ErrorSeverity.error => 'ERROR',
        ErrorSeverity.fatal => 'FATAL',
      };

  String get fingerprint {
    return <String>[
      exceptionType.trim().toLowerCase(),
      exceptionMessage.trim().toLowerCase(),
      firstStackFrame(stackTrace).trim().toLowerCase(),
    ].join('|');
  }

  String toTelegramMessage() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('🚨 Error Level: $severityLabel')
      ..writeln()
      ..writeln('👤 User')
      ..writeln('ID: ${_display(userId)}')
      ..writeln('Name: ${_display(userName)}')
      ..writeln('Email: ${_display(userEmail)}')
      ..writeln()
      ..writeln('📍 Navigation')
      ..writeln('Current Route: ${_display(currentRoute)}')
      ..writeln('Previous Route: ${_display(previousRoute)}')
      ..writeln('Navigation History: ${_display(navigationHistory.isEmpty ? null : navigationHistory.join(' -> '))}')
      ..writeln('Last User Action: ${_display(lastUserAction)}')
      ..writeln()
      ..writeln('🌐 API')
      ..writeln('Method: ${_display(apiMethod)}')
      ..writeln('URL: ${_display(apiUrl)}')
      ..writeln('Status Code: ${_display(apiStatusCode?.toString())}')
      ..writeln('Duration: ${_display(apiDuration == null ? null : '${apiDuration!.inMilliseconds}ms')}')
      ..writeln('Request Body: ${_display(apiRequestBody)}')
      ..writeln('Response Body: ${_display(apiResponseBody)}')
      ..writeln()
      ..writeln('📱 Device')
      ..writeln('Model: ${_display(deviceModel)}')
      ..writeln('Manufacturer: ${_display(deviceManufacturer)}')
      ..writeln('Android/iOS Version: ${_display(deviceOsVersion)}')
      ..writeln('Locale: ${_display(locale)}')
      ..writeln()
      ..writeln('📦 App')
      ..writeln('Version: ${_display(appVersion)}')
      ..writeln('Build Number: ${_display(buildNumber)}')
      ..writeln('Environment: ${_display(environment)}')
      ..writeln('Language: ${_display(language)}')
      ..writeln('Subscription Status: ${_display(subscriptionStatus)}')
      ..writeln()
      ..writeln('❌ Error')
      ..writeln('Exception Type: ${_display(exceptionType)}')
      ..writeln('Exception Message: ${_display(exceptionMessage)}')
      ..writeln()
      ..writeln('📚 Stack Trace')
      ..writeln(trimStackTrace(stackTrace))
      ..writeln()
      ..writeln('🕒 Timestamp')
      ..writeln(timestamp.toIso8601String());

    return truncateMessage(buffer.toString());
  }

  ErrorReport copyWith({
    ErrorSeverity? severity,
    String? exceptionType,
    String? exceptionMessage,
    String? stackTrace,
    DateTime? timestamp,
    String? userId,
    String? userName,
    String? userEmail,
    String? currentRoute,
    String? previousRoute,
    List<String>? navigationHistory,
    String? lastUserAction,
    String? apiMethod,
    String? apiUrl,
    int? apiStatusCode,
    Duration? apiDuration,
    String? apiRequestBody,
    String? apiResponseBody,
    String? deviceModel,
    String? deviceManufacturer,
    String? deviceOsVersion,
    String? locale,
    String? appVersion,
    String? buildNumber,
    String? environment,
    String? language,
    String? subscriptionStatus,
    String? source,
  }) {
    return ErrorReport(
      severity: severity ?? this.severity,
      exceptionType: exceptionType ?? this.exceptionType,
      exceptionMessage: exceptionMessage ?? this.exceptionMessage,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      currentRoute: currentRoute ?? this.currentRoute,
      previousRoute: previousRoute ?? this.previousRoute,
      navigationHistory: navigationHistory ?? this.navigationHistory,
      lastUserAction: lastUserAction ?? this.lastUserAction,
      apiMethod: apiMethod ?? this.apiMethod,
      apiUrl: apiUrl ?? this.apiUrl,
      apiStatusCode: apiStatusCode ?? this.apiStatusCode,
      apiDuration: apiDuration ?? this.apiDuration,
      apiRequestBody: apiRequestBody ?? this.apiRequestBody,
      apiResponseBody: apiResponseBody ?? this.apiResponseBody,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceManufacturer: deviceManufacturer ?? this.deviceManufacturer,
      deviceOsVersion: deviceOsVersion ?? this.deviceOsVersion,
      locale: locale ?? this.locale,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      environment: environment ?? this.environment,
      language: language ?? this.language,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      source: source ?? this.source,
    );
  }
}

String firstStackFrame(String stackTrace) {
  final List<String> lines = stackTrace
      .split('\n')
      .map((String line) => line.trim())
      .where((String line) => line.isNotEmpty)
      .toList(growable: false);
  return lines.isEmpty ? '' : lines.first;
}

String truncateMessage(
  String value, {
  int maxLength = 3900,
}) {
  if (value.length <= maxLength) {
    return value;
  }

  return '${value.substring(0, maxLength - 12)}\n...truncated';
}

String truncateBody(
  String value, {
  int maxLength = 1200,
}) {
  if (value.length <= maxLength) {
    return value;
  }

  return '${value.substring(0, maxLength - 12)}...truncated';
}

String trimStackTrace(String value, {int maxLines = 18}) {
  final List<String> lines = value
      .split('\n')
      .map((String line) => line.trimRight())
      .where((String line) => line.trim().isNotEmpty)
      .toList(growable: false);

  if (lines.length <= maxLines) {
    return lines.join('\n');
  }

  return <String>[
    ...lines.take(maxLines),
    '...truncated',
  ].join('\n');
}

String redactSensitiveText(String input) {
  final String sanitized = input
      .replaceAll(
    RegExp(
      r'\b(Bearer\s+)[A-Za-z0-9\-._~+/]+=*\b',
      caseSensitive: false,
    ),
        'Bearer ***',
      )
      .replaceAllMapped(
        RegExp(
          r'\b(password|pass|token|refreshToken|accessToken|authorization|cookie|cookies|jwt|secret|apiKey|clientSecret)\b\s*[:=]\s*[^,\s&]+',
        ),
        (Match match) => '${match.group(1)}: ***',
      );

  return sanitized;
}

dynamic redactSensitiveValue(dynamic value) {
  if (value is Map) {
    return value.map((Object? key, Object? item) {
      final String keyName = key?.toString().toLowerCase() ?? '';
      if (_isSensitiveKey(keyName)) {
        return MapEntry<Object?, Object?>(key, '***');
      }
      return MapEntry<Object?, Object?>(key, redactSensitiveValue(item));
    });
  }

  if (value is Iterable) {
    return value.map(redactSensitiveValue).toList(growable: false);
  }

  if (value is String) {
    return redactSensitiveText(value);
  }

  return value;
}

String encodeSanitizedBody(Object? value) {
  if (value == null) {
    return 'null';
  }

  try {
    final dynamic sanitized = redactSensitiveValue(value);
    return const JsonEncoder.withIndent('  ').convert(sanitized);
  } catch (_) {
    return redactSensitiveText(value.toString());
  }
}

bool _isSensitiveKey(String key) {
  return <String>{
    'password',
    'pass',
    'token',
    'refreshtoken',
    'accesstoken',
    'authorization',
    'cookie',
    'cookies',
    'jwt',
    'secret',
    'apikey',
    'clientsecret',
  }.contains(key.replaceAll(RegExp(r'[\s_\-]'), ''));
}

String _display(String? value) {
  final String? normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? 'Unknown' : redactSensitiveText(normalized);
}
