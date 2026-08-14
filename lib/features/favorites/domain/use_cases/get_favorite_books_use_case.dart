import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/favorite_book.dart';
import '../repositories/favorite_books_repository.dart';

class GetFavoriteBooksUseCase
    extends UseCase<Result<FavoriteBooksPage>, GetFavoriteBooksParams> {
  const GetFavoriteBooksUseCase(this._repository);

  final FavoriteBooksRepository _repository;

  @override
  Future<Result<FavoriteBooksPage>> call(GetFavoriteBooksParams params) {
    return _repository.getFavoriteBooks(
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      searchTerm: params.searchTerm,
    );
  }
}

class GetFavoriteBooksParams extends Equatable {
  const GetFavoriteBooksParams({
    this.pageNumber = 1,
    this.pageSize = 50,
    this.searchTerm = '',
  });

  final int pageNumber;
  final int pageSize;
  final String searchTerm;

  @override
  List<Object?> get props => <Object?>[pageNumber, pageSize, searchTerm];
}
