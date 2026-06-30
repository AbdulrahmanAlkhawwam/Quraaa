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
    String? categoryId,
  }) {
    return <String, Object?>{
      'firstName': ?firstName,
      'lastName': ?lastName,
      'phoneNumber': ?phoneNumber,
      'password': ?password,
      'gender': ?gender,
      'dateOfBirth': ?dateOfBirth,
      'categoryId': ?categoryId,
    };
  }

  static Map<String, Object?> loginToJson({
    required String phoneNumber,
    required String password,
  }) {
    return <String, Object?>{
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }

  static UserModel fromJson(Map<String, Object?> json) {
    return UserModel.fromJson(json);
  }

  static User toEntity(UserModel model) => model;
}
