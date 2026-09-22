import '../../../../core/use_cases/use_case.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class SaveProfileLocationUseCase
    extends UseCase<List<ProfileLocation>, ProfileLocation> {
  const SaveProfileLocationUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  FutureEither<List<ProfileLocation>> call(ProfileLocation params) {
    return _repository.updateLocation(params);
  }
}
