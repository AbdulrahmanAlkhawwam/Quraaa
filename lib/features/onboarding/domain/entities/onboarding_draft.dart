import 'gender_selection.dart';

class OnboardingDraft {
  const OnboardingDraft({
    required this.completed,
    required this.selectedGender,
    required this.selectedCategoryIds,
    required this.birthYear,
    required this.birthMonth,
    required this.birthDay,
  });

  /// Nothing answered yet. Also stands in when the saved draft can't be read,
  /// so startup routing can carry on instead of stalling.
  static const OnboardingDraft empty = OnboardingDraft(
    completed: false,
    selectedGender: null,
    selectedCategoryIds: null,
    birthYear: null,
    birthMonth: null,
    birthDay: null,
  );

  final bool completed;
  final GenderSelection? selectedGender;
  final List<String>? selectedCategoryIds;
  final int? birthYear;
  final int? birthMonth;
  final int? birthDay;
}
