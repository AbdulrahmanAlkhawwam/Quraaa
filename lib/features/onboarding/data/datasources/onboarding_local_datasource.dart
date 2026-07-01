import 'dart:convert';

import '../../../../core/services/storage_service.dart';
import '../../domain/entities/gender_selection.dart';
import '../../domain/entities/onboarding_draft.dart';
import '../models/category_model.dart';

abstract class OnboardingLocalDataSource {
  Future<OnboardingDraft> loadState();

  Future<void> saveBirthDate({
    required int year,
    required int month,
    required int day,
  });

  Future<void> saveGender(GenderSelection gender);

  Future<void> saveCategoryIds(List<String>? categoryIds);

  Future<void> completeOnboarding();

  Future<void> resetCompletion();

  Future<List<CategoryModel>?> getCachedCategories();

  Future<void> saveCachedCategories(List<CategoryModel> categories);
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  const OnboardingLocalDataSourceImpl(this._storageService);

  final StorageService _storageService;

  static const String _birthYearKey = 'birth_year';
  static const String _birthMonthKey = 'birth_month';
  static const String _birthDayKey = 'birth_day';
  static const String _genderKey = 'gender';
  static const String _selectedCategoryIdsKey = 'selected_category_ids';
  static const String _completedKey = 'onboarding_completed';
  static const String _categoriesCacheKey = 'categories_cache';

  @override
  Future<OnboardingDraft> loadState() async {
    final int? birthYear = _storageService.getInt(_birthYearKey);
    final int? birthMonth = _storageService.getInt(_birthMonthKey);
    final int? birthDay = _storageService.getInt(_birthDayKey);
    final String? storedGender = _storageService.getString(_genderKey);
    final List<String>? storedCategoryIds =
        _storageService.getStringList(_selectedCategoryIdsKey);
    final bool completed = _storageService.getBool(_completedKey) ?? false;

    return OnboardingDraft(
      completed: completed,
      selectedGender: GenderSelection.fromKey(storedGender),
      selectedCategoryIds: storedCategoryIds,
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
  Future<void> saveCategoryIds(List<String>? categoryIds) async {
    if (categoryIds == null || categoryIds.isEmpty) {
      await _storageService.remove(_selectedCategoryIdsKey);
    } else {
      await _storageService.setStringList(_selectedCategoryIdsKey, categoryIds);
    }
  }

  @override
  Future<void> completeOnboarding() async {
    await _storageService.setBool(_completedKey, true);
  }

  @override
  Future<void> resetCompletion() async {
    await _storageService.setBool(_completedKey, false);
  }

  @override
  Future<List<CategoryModel>?> getCachedCategories() async {
    final String? jsonString = _storageService.getString(_categoriesCacheKey);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCachedCategories(List<CategoryModel> categories) async {
    final List<Map<String, dynamic>> jsonList =
        categories.map((e) => e.toJson()).toList();
    await _storageService.setString(_categoriesCacheKey, jsonEncode(jsonList));
  }
}
