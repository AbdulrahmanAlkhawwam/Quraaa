import '../../../../core/use_cases/use_case.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileLocationsUseCase
    extends NoParamsUseCase<List<ProfileLocation>> {
  const GetProfileLocationsUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  FutureEither<List<ProfileLocation>> call() => _repository.getLocations();
}
