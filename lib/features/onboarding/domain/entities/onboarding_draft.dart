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

  final bool completed;
  final GenderSelection? selectedGender;
  final List<String>? selectedCategoryIds;
  final int? birthYear;
  final int? birthMonth;
  final int? birthDay;
}
