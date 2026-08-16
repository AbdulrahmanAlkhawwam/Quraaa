import '../../../../core/architecture/result.dart';
import '../entities/library_registration.dart';
import '../entities/library_profile.dart';

abstract class LibraryRegistrationRepository {
  const LibraryRegistrationRepository();

  Future<Result<LibraryRegistration>> requestRegistration();

  Future<Result<LibraryProfile?>> getMyProfile();
}
