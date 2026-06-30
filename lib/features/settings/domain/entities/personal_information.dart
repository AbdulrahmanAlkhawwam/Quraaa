import 'package:flutter/foundation.dart';

/// Immutable snapshot of a user's personal information.
///
/// This entity is intentionally plain: it holds only the data required by the
/// UI and does not depend on any state-management package.
@immutable
class PersonalInformation {
  const PersonalInformation({
    required this.name,
    required this.gender,
    required this.birthday,
    required this.phone,
    this.avatarUrl,
  });

  final String name;
  final String gender;
  final String birthday;
  final String phone;
  final String? avatarUrl;
}
