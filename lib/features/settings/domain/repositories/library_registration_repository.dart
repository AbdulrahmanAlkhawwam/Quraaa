import '../../../../core/architecture/result.dart';
import '../entities/library_registration.dart';

abstract class LibraryRegistrationRepository {
  const LibraryRegistrationRepository();

  Future<Result<LibraryRegistration>> requestRegistration();
}
