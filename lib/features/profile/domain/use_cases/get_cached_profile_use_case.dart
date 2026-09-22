import '../../../../core/use_cases/use_case.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetCachedProfileUseCase extends NoParamsUseCase<Profile?> {
  const GetCachedProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  FutureEither<Profile?> call() => _repository.getCachedProfile();
}
