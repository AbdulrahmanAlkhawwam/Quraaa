import '../../features/onboarding/domain/entities/gender_selection.dart';

class Validators {
  static bool requiredField(String? value) => value != null && value.trim().isNotEmpty;

  //region Name

  static bool nameNotEmpty(String? value) => value != null && value.trim().isNotEmpty;

  static bool nameMaxLength(String? value, {int maxLength = 50}) =>
      value != null && value.length <= maxLength;

  static String? validateName(
    String? value, {
    required String emptyError,
    required String maxLengthError,
    int maxLength = 50,
  }) {
    if (!nameNotEmpty(value)) return emptyError;
    if (!nameMaxLength(value, maxLength: maxLength)) return maxLengthError;
    return null;
  }

  //endregion

  //region Phone

  static bool phoneNotEmpty(String? value) => value != null && value.isNotEmpty;

  static bool phoneStartsWithPlus(String? value) => value != null && value.startsWith('+');

  static String? validatePhone(
    String? value, {
    required String emptyError,
    required String formatError,
    required bool isValid,
  }) {
    if (!phoneNotEmpty(value)) return emptyError;
    if (!isValid) return formatError;
    return null;
  }

  //endregion

  //region Password

  static bool passwordNotEmpty(String? value) => value != null && value.isNotEmpty;

  static bool passwordMinLength(String? value, {int minLength = 6}) =>
      value != null && value.length >= minLength;

  static bool passwordHasDigit(String? value) =>
      value != null && value.contains(RegExp(r'[0-9]'));

  static String? validatePassword(
    String? value, {
    required String emptyError,
    required String minLengthError,
    required String digitError,
    int minLength = 6,
  }) {
    if (!passwordNotEmpty(value)) return emptyError;
    if (!passwordMinLength(value, minLength: minLength)) return minLengthError;
    if (!passwordHasDigit(value)) return digitError;
    return null;
  }

  //endregion

  //region Date of Birth

  static bool dateOfBirthNotEmpty({
    required int? year,
    required int? month,
    required int? day,
  }) =>
      year != null && month != null && day != null;

  static bool dateOfBirthValid({
    required int? year,
    required int? month,
    required int? day,
  }) {
    if (!dateOfBirthNotEmpty(year: year, month: month, day: day)) return false;
    final int y = year!;
    final int m = month!;
    final int d = day!;
    try {
      final DateTime parsed = DateTime(y, m, d);
      return parsed.year == y && parsed.month == m && parsed.day == d;
    } catch (_) {
      return false;
    }
  }

  static bool dateOfBirthIsPast({
    required int? year,
    required int? month,
    required int? day,
  }) {
    if (!dateOfBirthValid(year: year, month: month, day: day)) return false;
    final DateTime birthDate = DateTime(year!, month!, day!);
    return !birthDate.isAfter(DateTime.now());
  }

  static bool dateOfBirthAgeInRange({
    required int? year,
    required int? month,
    required int? day,
    int minAge = 5,
    int maxAge = 100,
  }) {
    if (!dateOfBirthIsPast(year: year, month: month, day: day)) return false;

    final DateTime birthDate = DateTime(year!, month!, day!);
    final DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    final bool hasHadBirthdayThisYear = now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hasHadBirthdayThisYear) age--;

    return age >= minAge && age <= maxAge;
  }

  static String? validateDateOfBirth({
    required int? year,
    required int? month,
    required int? day,
    required String emptyError,
    required String invalidError,
    int minAge = 5,
    int maxAge = 100,
  }) {
    if (!dateOfBirthNotEmpty(year: year, month: month, day: day)) {
      return emptyError;
    }
    if (!dateOfBirthValid(year: year, month: month, day: day)) {
      return invalidError;
    }
    if (!dateOfBirthIsPast(year: year, month: month, day: day)) {
      return invalidError;
    }
    if (!dateOfBirthAgeInRange(
      year: year,
      month: month,
      day: day,
      minAge: minAge,
      maxAge: maxAge,
    )) {
      return invalidError;
    }
    return null;
  }

  //endregion

  //region Gender

  static bool genderValid(GenderSelection? gender) => gender != null;

  static String? validateGender(
    GenderSelection? gender, {
    required String invalidError,
  }) {
    if (!genderValid(gender)) return invalidError;
    return null;
  }

  //endregion

  //region Interests

  static bool interestsNotEmpty(List<String>? categoryIds) =>
      categoryIds != null && categoryIds.isNotEmpty;

  static bool interestsExist({
    required List<String>? categoryIds,
    required List<String> validCategoryIds,
  }) {
    if (!interestsNotEmpty(categoryIds)) return false;
    return categoryIds!.every((String id) => validCategoryIds.contains(id));
  }

  static String? validateInterests({
    required List<String>? categoryIds,
    required List<String> validCategoryIds,
    required String emptyError,
    required String invalidError,
  }) {
    if (!interestsNotEmpty(categoryIds)) return emptyError;
    if (!interestsExist(
      categoryIds: categoryIds,
      validCategoryIds: validCategoryIds,
    )) {
      return invalidError;
    }
    return null;
  }

  //endregion
}
