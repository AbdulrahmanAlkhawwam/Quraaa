import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/authors_repository.dart';

abstract class AuthorsRemoteDataSource {
  Future<AuthorEntity> getAuthor(String authorId);

  Future<AuthorBooksPage> getAuthorBooks(
    String authorId, {
    required int pageNumber,
    required int pageSize,
  });

  Future<AuthorSearchPage> searchAuthors(
    String searchTerm, {
    required int pageNumber,
    required int pageSize,
  });
}

class AuthorsRemoteDataSourceImpl implements AuthorsRemoteDataSource {
  const AuthorsRemoteDataSourceImpl(this._http);

  final HttpHelper _http;

  @override
  Future<AuthorEntity> getAuthor(String authorId) async {
    try {
      final Response<dynamic> response = await _http.get(
        ApiEndpoints.author(authorId),
      );
      final Map<String, dynamic> json = _requiredMap(response.data);
      return AuthorEntity(
        id: _text(json['id']),
        name: _text(json['name']),
        bio: _nullableText(json['bio']),
        photoUrl: _nullableText(json['photoUrl']),
        birthDate: DateTime.tryParse(_text(json['birthDate'])),
      );
    } on DioException catch (error) {
      throw _mapDio(error, 'Unable to load the author.');
    }
  }

  @override
  Future<AuthorBooksPage> getAuthorBooks(
    String authorId, {
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final Response<dynamic> response = await _http.get(
        ApiEndpoints.authorBooks(authorId),
        queryParameters: <String, dynamic>{
          'PageNumber': pageNumber,
          'PageSize': pageSize,
        },
      );
      final Map<String, dynamic> page = _requiredMap(response.data);
      final List<AuthorBookEntity> items = _items(page)
          .map((Map<String, dynamic> json) {
            final Map<String, dynamic> category = json['category'] is Map
                ? Map<String, dynamic>.from(json['category'] as Map)
                : const <String, dynamic>{};
            return AuthorBookEntity(
              listingId: _text(json['listingId']),
              title: _text(json['title']),
              authorName: _text(json['authorName']),
              coverImageUrl: _text(json['coverImageUrl']),
              format: _text(json['format']),
              startingPrice: _decimal(json['startingPrice']),
              isFree: json['isFree'] == true,
              sellersCount: _integer(json['sellersCount']),
              categoryNameAr: _text(category['nameAr']),
              categoryNameEn: _text(category['nameEn']),
              averageRating: _nullableDecimal(json['averageRating']),
              ratingsCount: _integer(json['ratingsCount']),
            );
          })
          .where((AuthorBookEntity book) => book.listingId.isNotEmpty)
          .toList(growable: false);
      return AuthorBooksPage(
        items: items,
        hasNextPage: page['hasNextPage'] == true,
      );
    } on DioException catch (error) {
      throw _mapDio(error, 'Unable to load author books.');
    }
  }

  @override
  Future<AuthorSearchPage> searchAuthors(
    String searchTerm, {
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final Response<dynamic> response = await _http.get(
        ApiEndpoints.authorSearch,
        queryParameters: <String, dynamic>{
          'SearchTerm': searchTerm.trim(),
          'PageNumber': pageNumber,
          'PageSize': pageSize,
        },
      );
      final Map<String, dynamic> page = _requiredMap(response.data);
      return AuthorSearchPage(
        items: _items(page)
            .map(
              (Map<String, dynamic> json) => AuthorSearchResult(
                id: _text(json['id']),
                name: _text(json['name']),
                photoUrl: _nullableText(json['photoUrl']),
                totalBooksCount: _integer(json['totalBooksCount']),
              ),
            )
            .where((AuthorSearchResult author) => author.id.isNotEmpty)
            .toList(growable: false),
        totalCount: _integer(page['totalCount']),
        hasNextPage: page['hasNextPage'] == true,
      );
    } on DioException catch (error) {
      throw _mapDio(error, 'Unable to search authors.');
    }
  }

  Map<String, dynamic> _requiredMap(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const UnknownException(message: 'Invalid author response.');
  }

  List<Map<String, dynamic>> _items(Map<String, dynamic> page) {
    final Object? raw = page['items'];
    if (raw is! List) return const <Map<String, dynamic>>[];
    return raw
        .whereType<Map>()
        .map((Map item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  AppException _mapDio(DioException error, String fallback) {
    if (error.error is AppException) return error.error! as AppException;
    if (error.response?.data is Map) {
      return ErrorMapper.mapResponseToException(
        ErrorResponseModel.fromJson(
          Map<String, dynamic>.from(error.response!.data as Map),
          statusCode: error.response?.statusCode,
        ),
      );
    }
    return UnknownException(message: error.message ?? fallback);
  }

  String _text(Object? value) => value?.toString().trim() ?? '';
  String? _nullableText(Object? value) {
    final String result = _text(value);
    return result.isEmpty ? null : result;
  }

  int _integer(Object? value) =>
      value is num ? value.toInt() : int.tryParse(_text(value)) ?? 0;
  double _decimal(Object? value) =>
      value is num ? value.toDouble() : double.tryParse(_text(value)) ?? 0;
  double? _nullableDecimal(Object? value) => value == null
      ? null
      : value is num
          ? value.toDouble()
          : double.tryParse(_text(value));
}
