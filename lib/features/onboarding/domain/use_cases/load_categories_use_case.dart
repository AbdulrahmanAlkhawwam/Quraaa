import '../../../../core/architecture/use_case.dart';
import '../entities/category.dart';
import '../repositories/onboarding_repository.dart';

class LoadCategoriesUseCase extends UseCase<List<Category>, NoParams> {
  const LoadCategoriesUseCase(this._repository);
  final OnboardingRepository _repository;
  @override
  Future<List<Category>> call(NoParams params) => _repository.getCategories();
}
