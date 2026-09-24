import '../../../../core/use_cases/use_case.dart';
import '../entities/category.dart';
import '../repositories/onboarding_repository.dart';

class LoadCategoriesUseCase extends NoParamsUseCase<List<Category>> {
  const LoadCategoriesUseCase(this._repository);
  final OnboardingRepository _repository;
  @override
  FutureEither<List<Category>> call() => _repository.getCategories();
}
