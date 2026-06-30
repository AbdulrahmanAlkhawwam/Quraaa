import '../../../../../core/services/storage_service.dart';
import '../../../domain/entities/gender_selection.dart';
import '../../../domain/entities/interest_selection.dart';
import '../../../domain/entities/onboarding_draft.dart';

abstract class OnboardingLocalDataSource {
  Future<OnboardingDraft> loadState();

  Future<void> saveBirthDate({
    required int year,
    required int month,
    required int day,
  });

  Future<void> saveGender(GenderSelection gender);

  Future<void> saveInterests(List<InterestSelection> interests);

  Future<void> completeOnboarding();

  Future<void> resetCompletion();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  const OnboardingLocalDataSourceImpl(this._storageService);

  final StorageService _storageService;

  static const String _birthYearKey = 'birth_year';
  static const String _birthMonthKey = 'birth_month';
  static const String _birthDayKey = 'birth_day';
  static const String _genderKey = 'gender';
  static const String _selectedInterestsKey = 'selected_interests';
  static const String _completedKey = 'onboarding_completed';

  @override
  Future<OnboardingDraft> loadState() async {
    final int? birthYear = _storageService.getInt(_birthYearKey);
    final int? birthMonth = _storageService.getInt(_birthMonthKey);
    final int? birthDay = _storageService.getInt(_birthDayKey);
    final String? storedGender = _storageService.getString(_genderKey);
    final List<String> storedInterests =
        _storageService.getStringList(_selectedInterestsKey) ?? [];
    final bool completed = _storageService.getBool(_completedKey) ?? false;

    return OnboardingDraft(
      completed: completed,
      selectedGender: GenderSelection.fromKey(storedGender),
      selectedInterests: storedInterests
          .map(InterestSelection.fromKey)
          .whereType<InterestSelection>()
          .toList(growable: false),
      birthYear: birthYear,
      birthMonth: birthMonth,
      birthDay: birthDay,
    );
  }

  @override
  Future<void> saveBirthDate({
    required int year,
    required int month,
    required int day,
  }) async {
    await _storageService.setInt(_birthYearKey, year);
    await _storageService.setInt(_birthMonthKey, month);
    await _storageService.setInt(_birthDayKey, day);
  }

  @override
  Future<void> saveGender(GenderSelection gender) async {
    await _storageService.setString(_genderKey, gender.key);
  }

  @override
  Future<void> saveInterests(List<InterestSelection> interests) async {
    await _storageService.setStringList(
      _selectedInterestsKey,
      interests
          .map((InterestSelection interest) => interest.key)
          .toList(growable: false),
    );
  }

  @override
  Future<void> completeOnboarding() async {
    await _storageService.setBool(_completedKey, true);
  }

  @override
  Future<void> resetCompletion() async {
    await _storageService.setBool(_completedKey, false);
  }
}
