import '../models/auth_user_model.dart';
import '../../domain/entities/auth_user.dart';

class AuthMapper {
  static AuthUser toEntity(AuthUserModel model) {
    return AuthUser(id: model.id, name: model.name);
  }
}
