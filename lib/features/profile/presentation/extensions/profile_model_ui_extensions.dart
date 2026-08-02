import 'package:easy_localization/easy_localization.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../domain/entities/profile.dart';

/// UI-oriented extensions for [Profile].
///
/// Keep all user-facing string resolution in the presentation layer rather
/// than inside the data model.
extension ProfileModelUiExtension on Profile {
  /// Localized gender label based on the integer [gender] value.
  String get localizedGenderLabel => localizedGenderLabelFromValue(gender);
}

/// Maps the backend gender integer to a localized label.
String localizedGenderLabelFromValue(int? gender) {
  return switch (gender) {
    ProfileGenderValue.male =>
      LocalizationConstants.userDataGenderMaleKey.tr(),
    ProfileGenderValue.female =>
      LocalizationConstants.userDataGenderFemaleKey.tr(),
    _ => '',
  };
}
