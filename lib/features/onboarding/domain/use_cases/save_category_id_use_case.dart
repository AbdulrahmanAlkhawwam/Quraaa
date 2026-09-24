import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../repositories/onboarding_repository.dart';

class SaveCategoryIdParams {
  const SaveCategoryIdParams(this.categoryIds);

  final List<String>? categoryIds;
}

class SaveCategoryIdUseCase extends UseCase<Unit, SaveCategoryIdParams> {
  const SaveCategoryIdUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  FutureEither<Unit> call(SaveCategoryIdParams params) {
    return _repository.saveCategoryIds(params.categoryIds);
  }
}
