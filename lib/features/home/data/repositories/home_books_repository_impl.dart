import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/home_books_page.dart';
import '../../domain/repositories/home_books_repository.dart';
import '../data_sources/home_books_remote_data_source.dart';
import '../models/paginated_home_books_response_model.dart';

class HomeBooksRepositoryImpl implements HomeBooksRepository {
  const HomeBooksRepositoryImpl(this._remoteDataSource);

  final HomeBooksRemoteDataSource _remoteDataSource;

  @override
  FutureEither<HomeBooksPage> getRecommendedBooks() {
    return _load(_remoteDataSource.getRecommendedBooks);
  }

  @override
  FutureEither<HomeBooksPage> getMostPopularBooks() {
    return _load(_remoteDataSource.getMostPopularBooks);
  }

  FutureEither<HomeBooksPage> _load(
    Future<PaginatedHomeBooksResponseModel> Function() request,
  ) async {
    try {
      return Right(_toPage(await request()));
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  HomeBooksPage _toPage(PaginatedHomeBooksResponseModel response) {
    return HomeBooksPage(
      items: response.items
          .map((model) => model.toEntity())
          .toList(growable: false),
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
      totalPages: response.totalPages,
      hasNextPage: response.hasNextPage,
      hasPreviousPage: response.hasPreviousPage,
    );
  }
}
