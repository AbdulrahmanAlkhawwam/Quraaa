import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/library_profile.dart';
import '../repositories/library_registration_repository.dart';

class GetLibraryProfileUseCase
    extends UseCase<Result<LibraryProfile?>, NoParams> {
  const GetLibraryProfileUseCase(this._repository);

  final LibraryRegistrationRepository _repository;

  @override
  Future<Result<LibraryProfile?>> call(NoParams params) {
    return _repository.getMyProfile();
  }
}
