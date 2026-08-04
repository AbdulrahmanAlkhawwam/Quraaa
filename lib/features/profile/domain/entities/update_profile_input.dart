import 'package:equatable/equatable.dart';

class UpdateProfileInput extends Equatable {
  const UpdateProfileInput({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.interestIds,
    this.profileImageUrl,
  });

  final String firstName;
  final String lastName;
  final int gender;
  final String dateOfBirth;
  final String? profileImageUrl;
  final List<String> interestIds;

  @override
  List<Object?> get props => <Object?>[
    firstName,
    lastName,
    gender,
    dateOfBirth,
    profileImageUrl,
    interestIds,
  ];
}
