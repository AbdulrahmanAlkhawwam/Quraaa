import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/book_summary_model.dart';

abstract class BookAssistantRemoteDataSource {
  Future<BookSummaryModel> summarize({required String purchaseId});
  Future<String> translate({
    required String purchaseId,
    required int pageNumber,
    required String targetLanguage,
  });
  Future<String> explain({
    required String purchaseId,
    required String selectedText,
  });
}

class BookAssistantRemoteDataSourceImpl
    implements BookAssistantRemoteDataSource {
  const BookAssistantRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<BookSummaryModel> summarize({required String purchaseId}) async {
    try {
      final Response<dynamic> response = await _httpHelper.post(
        ApiEndpoints.aiSummarize,
        data: <String, Object?>{'purchaseId': purchaseId},
      );
      final Object? data = response.data;
      if (data is Map) {
        final BookSummaryModel model = BookSummaryModel.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (model.summary.trim().isNotEmpty) {
          return model;
        }
      }
      throw const UnknownException(message: 'Invalid book summary response.');
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<String> translate({
    required String purchaseId,
    required int pageNumber,
    required String targetLanguage,
  }) =>
      _textRequest(
        ApiEndpoints.aiTranslate,
        <String, Object?>{
          'purchaseId': purchaseId,
          'pageNumber': pageNumber,
          'targetLanguage': targetLanguage,
        },
        'translatedText',
      );

  @override
  Future<String> explain({
    required String purchaseId,
    required String selectedText,
  }) =>
      _textRequest(
        ApiEndpoints.aiExplain,
        <String, Object?>{
          'purchaseId': purchaseId,
          'selectedText': selectedText,
        },
        'explanation',
      );

  Future<String> _textRequest(
    String endpoint,
    Map<String, Object?> body,
    String responseKey,
  ) async {
    try {
      final Response<dynamic> response = await _httpHelper.post(
        endpoint,
        data: body,
      );
      if (response.data is Map) {
        final String value =
            (response.data as Map)[responseKey]?.toString() ?? '';
        if (value.trim().isNotEmpty) return value;
      }
      throw const UnknownException(message: 'Invalid AI response.');
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) {
    final Object? underlying = error.error;
    if (underlying is AppException) return underlying;

    final Object? payload = error.response?.data;
    if (payload is Map) {
      return ErrorMapper.mapResponseToException(
        ErrorResponseModel.fromJson(
          Map<String, dynamic>.from(payload),
          statusCode: error.response?.statusCode,
        ),
      );
    }

    return UnknownException(
      message: error.message ?? 'Unable to summarize this book.',
    );
  }
}
