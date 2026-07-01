import '../../domain/entities/category.dart';
import '../../domain/entities/gender_selection.dart';
import '../../domain/entities/onboarding_draft.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';
import '../datasources/onboarding_remote_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final OnboardingLocalDataSource _localDataSource;
  final OnboardingRemoteDataSource _remoteDataSource;

  @override
  Future<OnboardingDraft> loadState() {
    return _localDataSource.loadState();
  }

  @override
  Future<void> saveBirthDate({
    required int year,
    required int month,
    required int day,
  }) {
    return _localDataSource.saveBirthDate(year: year, month: month, day: day);
  }

  @override
  Future<void> saveGender(GenderSelection gender) {
    return _localDataSource.saveGender(gender);
  }

  @override
  Future<void> saveCategoryIds(List<String>? categoryIds) {
    return _localDataSource.saveCategoryIds(categoryIds);
  }

  @override
  Future<List<Category>> getCategories() async {
    // 1. Try local cache first
    final cached = await _localDataSource.getCachedCategories();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // 2. Cache is empty → fetch from API
    final fresh = await _remoteDataSource.getCategories();

    // 3. Save to cache for next time
    await _localDataSource.saveCachedCategories(fresh);

    return fresh;
  }

  @override
  Future<void> completeOnboarding() {
    return _localDataSource.completeOnboarding();
  }

  @override
  Future<void> resetCompletion() {
    return _localDataSource.resetCompletion();
  }

  @override
  Future<bool> isCompleted() async {
    final OnboardingDraft draft = await _localDataSource.loadState();
    return draft.completed;
  }
}
