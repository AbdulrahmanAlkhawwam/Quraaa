import '../models/user_model.dart';
import '../../domain/entities/user.dart';

class AuthMapper {
  static Map<String, Object?> registerToJson({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? interests,
  }) {
    return <String, Object?>{
      'firstName': ?firstName,
      'lastName': ?lastName,
      'phoneNumber': ?phoneNumber,
      'password': ?password,
      'gender': ?gender,
      'dateOfBirth': ?dateOfBirth,
      'interests': ?interests,
    };
  }

  static UserModel fromJson(Map<String, Object?> json) {
    return UserModel.fromJson(json);
  }

  static User toEntity(UserModel model) => model;
}
