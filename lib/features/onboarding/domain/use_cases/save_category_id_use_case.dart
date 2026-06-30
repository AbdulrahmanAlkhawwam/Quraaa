import '../../../../core/architecture/use_case.dart';
import '../repositories/onboarding_repository.dart';

class SaveCategoryIdParams {
  const SaveCategoryIdParams(this.categoryId);

  final String? categoryId;
}

class SaveCategoryIdUseCase extends UseCase<void, SaveCategoryIdParams> {
  const SaveCategoryIdUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<void> call(SaveCategoryIdParams params) {
    return _repository.saveCategoryId(params.categoryId);
  }
}
