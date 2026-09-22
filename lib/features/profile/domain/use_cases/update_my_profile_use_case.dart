import '../../../../core/use_cases/use_case.dart';
import '../entities/profile.dart';
import '../entities/update_profile_input.dart';
import '../repositories/profile_repository.dart';

class UpdateMyProfileUseCase extends UseCase<Profile, UpdateProfileInput> {
  const UpdateMyProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  FutureEither<Profile> call(UpdateProfileInput params) {
    return _repository.updateMyProfile(params);
  }
}
