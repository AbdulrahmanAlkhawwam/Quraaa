import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/library_book_entity.dart';
import '../repositories/library_details_repository.dart';

class GetListingDetailsParams {
  const GetListingDetailsParams(this.listingId);

  final String listingId;
}

class GetListingDetailsUseCase
    extends UseCase<Result<LibraryBookEntity>, GetListingDetailsParams> {
  const GetListingDetailsUseCase(this._repository);

  final LibraryDetailsRepository _repository;

  @override
  Future<Result<LibraryBookEntity>> call(GetListingDetailsParams params) {
    return _repository.getListingDetails(params.listingId);
  }
}
