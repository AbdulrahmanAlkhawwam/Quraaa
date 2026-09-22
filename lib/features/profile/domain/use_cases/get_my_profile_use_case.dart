import '../../../../core/use_cases/use_case.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetMyProfileUseCase extends NoParamsUseCase<Profile> {
  const GetMyProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  FutureEither<Profile> call() => _repository.getMyProfile();
}
