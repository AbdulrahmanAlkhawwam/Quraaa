import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/library_registration.dart';
import '../repositories/library_registration_repository.dart';

class RequestLibraryRegistrationUseCase
    extends UseCase<Result<LibraryRegistration>, NoParams> {
  const RequestLibraryRegistrationUseCase(this._repository);

  final LibraryRegistrationRepository _repository;

  @override
  Future<Result<LibraryRegistration>> call(NoParams params) {
    return _repository.requestRegistration();
  }
}
