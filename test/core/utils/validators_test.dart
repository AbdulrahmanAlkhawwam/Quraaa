import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/utils/validators.dart';
import 'package:quraaa/features/onboarding/domain/entities/gender_selection.dart';

void main() {
  group('Validators.requiredField', () {
    test('returns false for null', () {
      expect(Validators.requiredField(null), isFalse);
    });

    test('returns false for empty or whitespace-only strings', () {
      expect(Validators.requiredField(''), isFalse);
      expect(Validators.requiredField('   '), isFalse);
    });

    test('returns true for non-empty strings', () {
      expect(Validators.requiredField('hello'), isTrue);
      expect(Validators.requiredField('  hello  '), isTrue);
    });
  });

  group('Validators.passwordNotEmpty', () {
    test('returns false for null or empty values', () {
      expect(Validators.passwordNotEmpty(null), isFalse);
      expect(Validators.passwordNotEmpty(''), isFalse);
    });

    test('returns true for any non-empty value', () {
      expect(Validators.passwordNotEmpty(' '), isTrue);
      expect(Validators.passwordNotEmpty('a'), isTrue);
    });
  });

  group('Validators.passwordMinLength', () {
    test('returns false when value is null or shorter than default 6', () {
      expect(Validators.passwordMinLength(null), isFalse);
      expect(Validators.passwordMinLength(''), isFalse);
      expect(Validators.passwordMinLength('12345'), isFalse);
    });

    test('returns true when value length is at least 6', () {
      expect(Validators.passwordMinLength('123456'), isTrue);
      expect(Validators.passwordMinLength('longer password'), isTrue);
    });

    test('respects custom minimum length', () {
      expect(Validators.passwordMinLength('12', minLength: 3), isFalse);
      expect(Validators.passwordMinLength('123', minLength: 3), isTrue);
    });
  });

  group('Validators.passwordHasDigit', () {
    test('returns false when value has no digits', () {
      expect(Validators.passwordHasDigit(null), isFalse);
      expect(Validators.passwordHasDigit(''), isFalse);
      expect(Validators.passwordHasDigit('abcdef'), isFalse);
      expect(Validators.passwordHasDigit('!@#\$%'), isFalse);
    });

    test('returns true when value contains at least one digit', () {
      expect(Validators.passwordHasDigit('a1'), isTrue);
      expect(Validators.passwordHasDigit('123456'), isTrue);
      expect(Validators.passwordHasDigit('pass9word'), isTrue);
    });
  });

  group('Validators.validatePassword', () {
    const String emptyError = 'Password is required.';
    const String minLengthError = 'Too short.';
    const String digitError = 'No digit.';

    test('returns emptyError for null or empty value', () {
      expect(
        Validators.validatePassword(
          null,
          emptyError: emptyError,
          minLengthError: minLengthError,
          digitError: digitError,
        ),
        emptyError,
      );
      expect(
        Validators.validatePassword(
          '',
          emptyError: emptyError,
          minLengthError: minLengthError,
          digitError: digitError,
        ),
        emptyError,
      );
    });

    test('returns minLengthError for short value', () {
      expect(
        Validators.validatePassword(
          'abc1',
          emptyError: emptyError,
          minLengthError: minLengthError,
          digitError: digitError,
        ),
        minLengthError,
      );
    });

    test('returns digitError for value without digits', () {
      expect(
        Validators.validatePassword(
          'abcdef',
          emptyError: emptyError,
          minLengthError: minLengthError,
          digitError: digitError,
        ),
        digitError,
      );
    });

    test('returns null for valid password', () {
      expect(
        Validators.validatePassword(
          'abc123',
          emptyError: emptyError,
          minLengthError: minLengthError,
          digitError: digitError,
        ),
        isNull,
      );
    });

    test('reports empty error before min-length and digit errors', () {
      expect(
        Validators.validatePassword(
          '',
          emptyError: emptyError,
          minLengthError: minLengthError,
          digitError: digitError,
        ),
        emptyError,
      );
    });

    test('reports min-length error before digit error', () {
      expect(
        Validators.validatePassword(
          'abcde',
          emptyError: emptyError,
          minLengthError: minLengthError,
          digitError: digitError,
        ),
        minLengthError,
      );
    });
  });

  group('Validators.nameNotEmpty', () {
    test('returns false for null or whitespace-only values', () {
      expect(Validators.nameNotEmpty(null), isFalse);
      expect(Validators.nameNotEmpty(''), isFalse);
      expect(Validators.nameNotEmpty('   '), isFalse);
    });

    test('returns true for non-empty values', () {
      expect(Validators.nameNotEmpty('A'), isTrue);
      expect(Validators.nameNotEmpty('  John  '), isTrue);
    });
  });

  group('Validators.nameMaxLength', () {
    test('returns false when value exceeds max length', () {
      expect(Validators.nameMaxLength('a' * 51), isFalse);
      expect(
        Validators.nameMaxLength('abc', maxLength: 2),
        isFalse,
      );
    });

    test('returns true when value length is within limit', () {
      expect(Validators.nameMaxLength('a' * 50), isTrue);
      expect(Validators.nameMaxLength('abc', maxLength: 3), isTrue);
    });
  });

  group('Validators.validateName', () {
    const String emptyError = 'Name is required.';
    const String maxLengthError = 'Name too long.';

    test('returns emptyError for null or whitespace-only value', () {
      expect(
        Validators.validateName(
          null,
          emptyError: emptyError,
          maxLengthError: maxLengthError,
        ),
        emptyError,
      );
      expect(
        Validators.validateName(
          '  ',
          emptyError: emptyError,
          maxLengthError: maxLengthError,
        ),
        emptyError,
      );
    });

    test('returns maxLengthError for overly long value', () {
      expect(
        Validators.validateName(
          'a' * 51,
          emptyError: emptyError,
          maxLengthError: maxLengthError,
        ),
        maxLengthError,
      );
    });

    test('returns null for valid name', () {
      expect(
        Validators.validateName(
          'John',
          emptyError: emptyError,
          maxLengthError: maxLengthError,
        ),
        isNull,
      );
    });
  });

  group('Validators.phoneNotEmpty', () {
    test('returns false for null or empty value', () {
      expect(Validators.phoneNotEmpty(null), isFalse);
      expect(Validators.phoneNotEmpty(''), isFalse);
    });

    test('returns true for non-empty value', () {
      expect(Validators.phoneNotEmpty('+123'), isTrue);
    });
  });

  group('Validators.phoneStartsWithPlus', () {
    test('returns false when value does not start with +', () {
      expect(Validators.phoneStartsWithPlus(null), isFalse);
      expect(Validators.phoneStartsWithPlus('123'), isFalse);
      expect(Validators.phoneStartsWithPlus('  +123'), isFalse);
    });

    test('returns true when value starts with +', () {
      expect(Validators.phoneStartsWithPlus('+123'), isTrue);
    });
  });

  group('Validators.validatePhone', () {
    const String emptyError = 'Phone required.';
    const String formatError = 'Phone format invalid.';

    test('returns emptyError when value is null or empty', () {
      expect(
        Validators.validatePhone(
          null,
          emptyError: emptyError,
          formatError: formatError,
          isValid: true,
        ),
        emptyError,
      );
      expect(
        Validators.validatePhone(
          '',
          emptyError: emptyError,
          formatError: formatError,
          isValid: true,
        ),
        emptyError,
      );
    });

    test('returns formatError when isValid is false', () {
      expect(
        Validators.validatePhone(
          '+123',
          emptyError: emptyError,
          formatError: formatError,
          isValid: false,
        ),
        formatError,
      );
    });

    test('returns null for valid phone', () {
      expect(
        Validators.validatePhone(
          '+1234567890',
          emptyError: emptyError,
          formatError: formatError,
          isValid: true,
        ),
        isNull,
      );
    });
  });

  group('Validators.dateOfBirth', () {
    test('dateOfBirthNotEmpty returns false when any part is null', () {
      expect(
        Validators.dateOfBirthNotEmpty(year: 2000, month: 1, day: null),
        isFalse,
      );
      expect(
        Validators.dateOfBirthNotEmpty(year: null, month: 1, day: 1),
        isFalse,
      );
    });

    test('dateOfBirthNotEmpty returns true when all parts are present', () {
      expect(
        Validators.dateOfBirthNotEmpty(year: 2000, month: 1, day: 1),
        isTrue,
      );
    });

    test('dateOfBirthValid returns false for invalid calendar dates', () {
      expect(
        Validators.dateOfBirthValid(year: 2000, month: 2, day: 30),
        isFalse,
      );
      expect(
        Validators.dateOfBirthValid(year: 2000, month: 13, day: 1),
        isFalse,
      );
    });

    test('dateOfBirthValid returns true for valid calendar dates', () {
      expect(
        Validators.dateOfBirthValid(year: 2000, month: 2, day: 29),
        isTrue,
      );
      expect(
        Validators.dateOfBirthValid(year: 2000, month: 12, day: 31),
        isTrue,
      );
    });

    test('dateOfBirthIsPast returns false for future dates', () {
      final DateTime future = DateTime.now().add(const Duration(days: 365));
      expect(
        Validators.dateOfBirthIsPast(
          year: future.year,
          month: future.month,
          day: future.day,
        ),
        isFalse,
      );
    });

    test('dateOfBirthAgeInRange returns false outside 5-100', () {
      final DateTime now = DateTime.now();
      expect(
        Validators.dateOfBirthAgeInRange(
          year: now.year - 1,
          month: now.month,
          day: now.day,
        ),
        isFalse,
      );
      expect(
        Validators.dateOfBirthAgeInRange(
          year: now.year - 101,
          month: now.month,
          day: now.day,
        ),
        isFalse,
      );
    });

    test('dateOfBirthAgeInRange returns true for age exactly at boundaries', () {
      final DateTime now = DateTime.now();
      expect(
        Validators.dateOfBirthAgeInRange(
          year: now.year - 5,
          month: now.month,
          day: now.day,
        ),
        isTrue,
      );
      expect(
        Validators.dateOfBirthAgeInRange(
          year: now.year - 100,
          month: now.month,
          day: now.day,
        ),
        isTrue,
      );
    });

    test('validateDateOfBirth reports empty before invalid', () {
      const String emptyError = 'DOB required.';
      const String invalidError = 'DOB invalid.';
      expect(
        Validators.validateDateOfBirth(
          year: null,
          month: 1,
          day: 1,
          emptyError: emptyError,
          invalidError: invalidError,
        ),
        emptyError,
      );
    });

    test('validateDateOfBirth returns invalidError for future date', () {
      const String emptyError = 'DOB required.';
      const String invalidError = 'DOB invalid.';
      final DateTime future = DateTime.now().add(const Duration(days: 365));
      expect(
        Validators.validateDateOfBirth(
          year: future.year,
          month: future.month,
          day: future.day,
          emptyError: emptyError,
          invalidError: invalidError,
        ),
        invalidError,
      );
    });

    test('validateDateOfBirth returns null for valid adult date', () {
      const String emptyError = 'DOB required.';
      const String invalidError = 'DOB invalid.';
      final DateTime now = DateTime.now();
      expect(
        Validators.validateDateOfBirth(
          year: now.year - 20,
          month: now.month,
          day: now.day,
          emptyError: emptyError,
          invalidError: invalidError,
        ),
        isNull,
      );
    });
  });

  group('Validators.genderValid', () {
    test('returns false for null', () {
      expect(Validators.genderValid(null), isFalse);
    });

    test('returns true for valid enum values', () {
      expect(Validators.genderValid(GenderSelection.boy), isTrue);
      expect(Validators.genderValid(GenderSelection.girl), isTrue);
    });
  });

  group('Validators.validateGender', () {
    const String invalidError = 'Gender invalid.';

    test('returns invalidError for null', () {
      expect(
        Validators.validateGender(null, invalidError: invalidError),
        invalidError,
      );
    });

    test('returns null for valid gender', () {
      expect(
        Validators.validateGender(
          GenderSelection.boy,
          invalidError: invalidError,
        ),
        isNull,
      );
    });
  });

  group('Validators.interests', () {
    const List<String> validIds = <String>['uuid-1', 'uuid-2'];

    test('interestsNotEmpty returns false for null or empty list', () {
      expect(Validators.interestsNotEmpty(null), isFalse);
      expect(Validators.interestsNotEmpty(<String>[]), isFalse);
    });

    test('interestsNotEmpty returns true for non-empty list', () {
      expect(Validators.interestsNotEmpty(<String>['uuid-1']), isTrue);
    });

    test('interestsExist returns false when list contains invalid ids', () {
      expect(
        Validators.interestsExist(
          categoryIds: <String>['uuid-1', 'unknown'],
          validCategoryIds: validIds,
        ),
        isFalse,
      );
    });

    test('interestsExist returns true when all ids are valid', () {
      expect(
        Validators.interestsExist(
          categoryIds: validIds,
          validCategoryIds: validIds,
        ),
        isTrue,
      );
    });

    test('validateInterests reports empty before invalid', () {
      const String emptyError = 'Interests required.';
      const String invalidError = 'Interests invalid.';
      expect(
        Validators.validateInterests(
          categoryIds: null,
          validCategoryIds: validIds,
          emptyError: emptyError,
          invalidError: invalidError,
        ),
        emptyError,
      );
      expect(
        Validators.validateInterests(
          categoryIds: <String>[],
          validCategoryIds: validIds,
          emptyError: emptyError,
          invalidError: invalidError,
        ),
        emptyError,
      );
    });

    test('validateInterests returns invalidError for unknown ids', () {
      const String emptyError = 'Interests required.';
      const String invalidError = 'Interests invalid.';
      expect(
        Validators.validateInterests(
          categoryIds: <String>['uuid-1', 'unknown'],
          validCategoryIds: validIds,
          emptyError: emptyError,
          invalidError: invalidError,
        ),
        invalidError,
      );
    });

    test('validateInterests returns null for valid selection', () {
      const String emptyError = 'Interests required.';
      const String invalidError = 'Interests invalid.';
      expect(
        Validators.validateInterests(
          categoryIds: validIds,
          validCategoryIds: validIds,
          emptyError: emptyError,
          invalidError: invalidError,
        ),
        isNull,
      );
    });
  });
}