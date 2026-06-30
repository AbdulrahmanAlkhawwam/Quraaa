import 'gender_selection.dart';
import 'interest_selection.dart';

class OnboardingDraft {
  const OnboardingDraft({
    required this.completed,
    required this.selectedGender,
    required this.selectedInterests,
    required this.birthYear,
    required this.birthMonth,
    required this.birthDay,
  });

  final bool completed;
  final GenderSelection? selectedGender;
  final List<InterestSelection> selectedInterests;
  final int? birthYear;
  final int? birthMonth;
  final int? birthDay;
}
