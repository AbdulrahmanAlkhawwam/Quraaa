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
    List<String>? categoryIds,
  }) {
    return <String, Object?>{
      'firstName': ?firstName,
      'lastName': ?lastName,
      'phoneNumber': ?phoneNumber,
      'password': ?password,
      'gender': ?gender,
      'dateOfBirth': ?dateOfBirth,
      'Interests': ?categoryIds,
    };
  }

  static Map<String, Object?> loginToJson({
    required String phoneNumber,
    required String password,
  }) {
    return <String, Object?>{'phoneNumber': phoneNumber, 'password': password};
  }

  static Map<String, Object?> verifyOtpToJson({
    required String phoneNumber,
    required String code,
  }) {
    return <String, Object?>{'phoneNumber': phoneNumber, 'code': code};
  }

  static Map<String, Object?> forgotPasswordToJson({
    required String phoneNumber,
  }) {
    return <String, Object?>{'phoneNumber': phoneNumber};
  }

  static Map<String, Object?> resetPasswordToJson({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) {
    return <String, Object?>{
      'phoneNumber': phoneNumber,
      'code': code,
      'newPassword': newPassword,
    };
  }

  static UserModel fromJson(Map<String, Object?> json) {
    return UserModel.fromJson(json);
  }

  static User toEntity(UserModel model) => model;
}
