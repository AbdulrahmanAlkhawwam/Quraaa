import '../../../../core/architecture/use_case.dart';
import '../repositories/onboarding_repository.dart';

class SaveCategoryIdParams {
  const SaveCategoryIdParams(this.categoryIds);

  final List<String>? categoryIds;
}

class SaveCategoryIdUseCase extends UseCase<void, SaveCategoryIdParams> {
  const SaveCategoryIdUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<void> call(SaveCategoryIdParams params) {
    return _repository.saveCategoryIds(params.categoryIds);
  }
}
