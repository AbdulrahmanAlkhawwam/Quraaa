import '../../domain/entities/gender_selection.dart';
import '../../domain/entities/interest_selection.dart';
import '../../domain/entities/onboarding_draft.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/local/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._localDataSource);

  final OnboardingLocalDataSource _localDataSource;

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
  Future<void> saveInterests(List<InterestSelection> interests) {
    return _localDataSource.saveInterests(interests);
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
