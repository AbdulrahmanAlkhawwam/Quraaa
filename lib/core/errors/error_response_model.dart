class ErrorResponseModel {
  const ErrorResponseModel({
    this.error,
    this.errors = const <String, dynamic>{},
  });

  final ErrorResponseDetail? error;
  final Map<String, dynamic> errors;

  String? get code => error?.code ?? _firstDetail?.code;
  String? get title => error?.title ?? _firstDetail?.title;
  String? get message => error?.message ?? _firstDetail?.message;

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

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    return ErrorResponseModel(
      error: _parseDetail(json['error']),
      errors: _parseErrors(json['errors']),
    );
  }

  static Map<String, dynamic> _parseErrors(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
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
        json.containsKey('detail');
  }
}

class ErrorResponseDetail {
  const ErrorResponseDetail({
    this.code,
    this.title,
    this.message,
  });

  final String? code;
  final String? title;
  final String? message;

  factory ErrorResponseDetail.fromJson(Map<String, dynamic> json) {
    return ErrorResponseDetail(
      code: _asString(json['code']),
      title: _asString(json['title']),
      message: _asString(json['message']) ?? _asString(json['detail']),
    );
  }

  static String? _asString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }
}
