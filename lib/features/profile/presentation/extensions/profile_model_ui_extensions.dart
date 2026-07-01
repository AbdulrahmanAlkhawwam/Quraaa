import 'package:easy_localization/easy_localization.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../data/models/profile_model.dart';

/// UI-oriented extensions for [ProfileModel].
///
/// Keep all user-facing string resolution in the presentation layer rather
/// than inside the data model.
extension ProfileModelUiExtension on ProfileModel {
  /// Localized gender label based on the integer [gender] value.
  String get localizedGenderLabel => localizedGenderLabelFromValue(gender);
}

/// Maps the backend gender integer to a localized label.
String localizedGenderLabelFromValue(int? gender) {
  return switch (gender) {
    0 => LocalizationConstants.userDataGenderMaleKey.tr(),
    1 => LocalizationConstants.userDataGenderFemaleKey.tr(),
    2 => LocalizationConstants.userDataGenderPreferNotToSayKey.tr(),
    _ => '',
  };
}
