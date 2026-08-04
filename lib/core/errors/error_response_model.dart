class ErrorResponseModel {
  const ErrorResponseModel({
    this.error,
    this.errors = const <String, dynamic>{},
    this.statusCode,
  });

  final ErrorResponseDetail? error;
  final Map<String, dynamic> errors;
  final int? statusCode;

  String? get code => error?.code ?? _firstDetail?.code;
  String? get title => error?.title ?? _firstDetail?.title;
  String? get message {
    final List<String> validationMessages = _validationMessages;
    if (validationMessages.isNotEmpty) {
      return validationMessages.take(4).join('\n');
    }
    return error?.message ?? _firstDetail?.message;
  }

  bool get hasErrors => error != null || errors.isNotEmpty;

  ErrorResponseDetail? get _firstDetail {
    final ErrorResponseDetail? parsedError = _detailFromMap(errors);
    if (parsedError != null) {
      return parsedError;
    }

    for (final dynamic value in errors.values) {
      final ErrorResponseDetail? detail = _parseDetail(value);
      if (detail != null) {
        return detail;
      }
    }

    return null;
  }

  factory ErrorResponseModel.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    final ErrorResponseDetail? topLevelDetail = _detailFromMap(json);
    final ErrorResponseDetail? nestedDetail = _parseDetail(json['error']);
    return ErrorResponseModel(
      error: _mergeDetails(topLevelDetail, nestedDetail),
      errors: _parseErrors(json['errors']),
      statusCode:
          statusCode ??
          _asInt(json['statusCode']) ??
          _asInt(json['status']) ??
          _asInt(json['status_code']),
    );
  }

  List<String> get _validationMessages {
    final List<String> messages = <String>[];
    for (final dynamic value in errors.values) {
      _appendMessages(value, messages);
    }
    return messages.toSet().toList(growable: false);
  }

  static ErrorResponseDetail? _mergeDetails(
    ErrorResponseDetail? topLevel,
    ErrorResponseDetail? nested,
  ) {
    if (topLevel == null) return nested;
    if (nested == null) return topLevel;
    return ErrorResponseDetail(
      code: nested.code ?? topLevel.code,
      title: nested.title ?? topLevel.title,
      message: topLevel.message ?? nested.message,
    );
  }

  static void _appendMessages(dynamic value, List<String> messages) {
    if (value is String) {
      final String normalized = value.trim();
      if (normalized.isNotEmpty) messages.add(normalized);
      return;
    }
    if (value is Iterable) {
      for (final dynamic item in value) {
        _appendMessages(item, messages);
      }
      return;
    }
    if (value is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(value);
      final ErrorResponseDetail? detail = _detailFromMap(map);
      if (detail?.message != null) {
        _appendMessages(detail!.message, messages);
        return;
      }
      for (final dynamic item in map.values) {
        _appendMessages(item, messages);
      }
    }
  }

  static Map<String, dynamic> _parseErrors(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is Iterable) {
      final Map<String, dynamic> parsed = <String, dynamic>{};
      var unnamedIndex = 0;
      for (final dynamic item in value) {
        if (item is! Map) continue;
        final Map<String, dynamic> error = Map<String, dynamic>.from(item);
        final String field =
            _asNonEmptyString(error['field']) ?? 'error_${unnamedIndex++}';
        final dynamic message =
            error['message'] ?? error['detail'] ?? error['errorMessage'];
        if (message == null) continue;

        final dynamic existing = parsed[field];
        if (existing == null) {
          parsed[field] = message;
        } else if (existing is List<dynamic>) {
          existing.add(message);
        } else {
          parsed[field] = <dynamic>[existing, message];
        }
      }
      return parsed;
    }

    return <String, dynamic>{};
  }

  static String? _asNonEmptyString(dynamic value) {
    if (value is! String) return null;
    final String normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  static ErrorResponseDetail? _parseDetail(dynamic value) {
    if (value is ErrorResponseDetail) {
      return value;
    }

    if (value is Map<String, dynamic>) {
      return _detailFromMap(value);
    }

    if (value is Map) {
      return _detailFromMap(Map<String, dynamic>.from(value));
    }

    if (value is String) {
      return ErrorResponseDetail(message: value);
    }

    if (value is Iterable && value.isNotEmpty) {
      final dynamic first = value.first;
      if (first is String) {
        return ErrorResponseDetail(message: first);
      }

      return _parseDetail(first);
    }

    return null;
  }

  static ErrorResponseDetail? _detailFromMap(Map<String, dynamic> json) {
    if (!_hasDetailShape(json)) {
      return null;
    }

    return ErrorResponseDetail.fromJson(json);
  }

  static bool _hasDetailShape(Map<String, dynamic> json) {
    return json.containsKey('code') ||
        json.containsKey('title') ||
        json.containsKey('message') ||
        json.containsKey('detail') ||
        json.containsKey('error_description') ||
        json.containsKey('errorMessage');
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}

class ErrorResponseDetail {
  const ErrorResponseDetail({this.code, this.title, this.message});

  final String? code;
  final String? title;
  final String? message;

  factory ErrorResponseDetail.fromJson(Map<String, dynamic> json) {
    return ErrorResponseDetail(
      code: _asString(json['code']),
      title: _asString(json['title']),
      message:
          _asString(json['message']) ??
          _asString(json['detail']) ??
          _asString(json['error_description']) ??
          _asString(json['errorMessage']),
    );
  }

  static String? _asString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }
}
