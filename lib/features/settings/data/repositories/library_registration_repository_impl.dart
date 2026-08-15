import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/library_registration.dart';
import '../../domain/repositories/library_registration_repository.dart';
import '../datasources/library_registration_remote_data_source.dart';
import '../models/library_registration_model.dart';

class LibraryRegistrationRepositoryImpl
    implements LibraryRegistrationRepository {
  const LibraryRegistrationRepositoryImpl(this._remoteDataSource);

  final LibraryRegistrationRemoteDataSource _remoteDataSource;

  @override
  Future<Result<LibraryRegistration>> requestRegistration() async {
    try {
      final LibraryRegistrationModel model =
          await _remoteDataSource.requestRegistration();
      return Success<LibraryRegistration>(model.toEntity());
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<LibraryRegistration>(
        failure.message,
        cause: failure,
      );
    }
  }
}
