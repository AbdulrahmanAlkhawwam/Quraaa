import '../../domain/entities/update_profile_input.dart';

class UpdateProfileRequestModel {
  const UpdateProfileRequestModel(this.input);

  final UpdateProfileInput input;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'firstName': input.firstName,
    'lastName': input.lastName,
    'gender': input.gender,
    'dateOfBirth': input.dateOfBirth,
    'profileImageUrl': input.profileImageUrl ?? '',
    'interests': input.interestIds,
  };
}
