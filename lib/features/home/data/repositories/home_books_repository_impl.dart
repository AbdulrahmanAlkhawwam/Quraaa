import '../../../../core/architecture/base_repository.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/home_book_entity.dart';
import '../../domain/repositories/home_books_repository.dart';
import '../datasources/home_books_remote_data_source.dart';
import '../models/paginated_home_books_response_model.dart';

class HomeBooksRepositoryImpl extends BaseRepository<HomeBooksPage>
    implements HomeBooksRepository {
  const HomeBooksRepositoryImpl(this._remoteDataSource);

  final HomeBooksRemoteDataSource _remoteDataSource;

  @override
  Future<Result<HomeBooksPage>> getRecommendedBooks() {
    return _load(_remoteDataSource.getRecommendedBooks);
  }

  @override
  Future<Result<HomeBooksPage>> getMostPopularBooks() {
    return _load(_remoteDataSource.getMostPopularBooks);
  }

  Future<Result<HomeBooksPage>> _load(
    Future<PaginatedHomeBooksResponseModel> Function() request,
  ) async {
    try {
      final PaginatedHomeBooksResponseModel response = await request();
      return Success<HomeBooksPage>(_toPage(response));
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<HomeBooksPage>(failure.message, cause: failure);
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

  @override
  Future<HomeBooksPage> getCached() async => _emptyPage;

  @override
  Future<HomeBooksPage> sync() async => _emptyPage;

  static const HomeBooksPage _emptyPage = HomeBooksPage(
    items: <HomeBookEntity>[],
    pageNumber: '0',
    pageSize: '0',
    totalCount: '0',
    totalPages: '0',
    hasNextPage: false,
    hasPreviousPage: false,
  );
}
