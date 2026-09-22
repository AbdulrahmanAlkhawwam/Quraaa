import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../../domain/entities/sell_book.dart';
import '../../domain/entities/my_listing.dart';

abstract interface class SellBookRemoteDataSource {
  Future<String> submitPhysicalBook(SellBookDraft draft);
  Future<List<MyListing>> getMyListings({String query = ''});
}

class SellBookRemoteDataSourceImpl implements SellBookRemoteDataSource {
  const SellBookRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<List<MyListing>> getMyListings({String query = ''}) async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.myListings,
        queryParameters: <String, dynamic>{
          if (query.trim().isNotEmpty) 'SearchTerm': query.trim(),
          'SortDescending': true,
        },
      );
      final Object? raw = response.data is Map
          ? (response.data as Map)['items']
          : response.data;
      if (raw is! List) return const <MyListing>[];
      return raw.whereType<Map>().map((Map item) {
        final Map<String, dynamic> json = Map<String, dynamic>.from(item);
        final Map<String, dynamic> book = json['book'] is Map
            ? Map<String, dynamic>.from(json['book'] as Map)
            : const <String, dynamic>{};
        return MyListing(
          listingId: json['listingId']?.toString() ?? '',
          bookId: book['bookId']?.toString() ?? '',
          title: book['title']?.toString() ?? '',
          author: book['author']?.toString() ?? '',
          coverImageUrl: book['coverImageUrl']?.toString() ?? '',
          price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
          stock: int.tryParse(json['stock']?.toString() ?? '') ?? 0,
          condition: json['condition']?.toString() ?? '',
          format: json['format']?.toString() ?? '',
          status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
        );
      }).toList(growable: false);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<String> submitPhysicalBook(SellBookDraft draft) async {
    if (draft.images.length != 1) {
      throw const ValidationException(
        message: 'Exactly one book image is required.',
      );
    }

    final SellBookImage image = draft.images.single;
    try {
      final String isbn = draft.isbn?.trim() ?? '';
      if (isbn.isEmpty) {
        throw const ValidationException(message: 'Book ISBN is required.');
      }
      if (draft.method == SellBookMethod.isbn) {
        final Response<dynamic> validation = await _httpHelper.get(
          ApiEndpoints.validateIsbn(isbn),
        );
        if (validation.data != true) {
          throw const ValidationException(
            message: 'No published book was found for the entered ISBN.',
          );
        }
      }

      final FormData formData = FormData.fromMap(<String, Object?>{
        'Price': draft.price,
        'Condition': _conditionValue(draft.condition),
        'Isbn': isbn,
        'CoverImage': await MultipartFile.fromFile(
          image.path,
          filename: image.name,
        ),
      });
      final Response<dynamic> response = await _httpHelper.post(
        ApiEndpoints.userPhysicalListings,
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
      final Object? data = response.data;
      if (data is Map && data['id'] != null) {
        return data['id'].toString();
      }
      throw const UnknownException(
        message: 'Invalid publish book response.',
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  int _conditionValue(SellBookCondition condition) {
    return switch (condition) {
      SellBookCondition.newBook => 1,
      SellBookCondition.used => 3,
      SellBookCondition.refurbished => 2,
    };
  }

  AppException _mapDioException(DioException error) {
    if (error.response?.statusCode == 404) {
      return const NotFoundException(
        message: 'No published book was found for the entered ISBN.',
      );
    }

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
    return UnknownException(message: error.message);
  }
}
