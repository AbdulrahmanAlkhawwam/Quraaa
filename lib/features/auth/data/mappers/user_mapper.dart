
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

class UserMapper {
  const UserMapper._();

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }

  static Map<String, dynamic> toJson(UserModel model) => model.toJson();

  static UserModel toModel(User entity) {
    if (entity is UserModel) return entity;
    return UserModel(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phoneNumber: entity.phoneNumber,
      country: entity.country,
      password: entity.password,
      interests: entity.interests,
      birthday: entity.birthday,
      gender: entity.gender,
      location: entity.location,
      language: entity.language,
      deviceAndroidVersion: entity.deviceAndroidVersion,
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      accessTokenExpiration: entity.accessTokenExpiration,
    );
  }

  static User toEntity(UserModel model) => model;

  static String toRawJson(UserModel model) => model.toRawJson();

  static UserModel fromRawJson(String raw) => UserModel.fromRawJson(raw);

  static Map<String, Object?> registerToJson({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? country,
    String? password,
    String? gender,
    String? birthday,
    List<String>? interests,
  }) {
    return <String, Object?>{
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'country': country,
      'password': password,
      'gender': gender,
      'birthday': birthday,
      'interests': interests,
    };
  }
}
