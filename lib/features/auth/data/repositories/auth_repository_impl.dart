import '../../../../core/architecture/base_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends BaseRepository<AuthUser>
    implements AuthRepository {
  const AuthRepositoryImpl();

  @override
  Future<AuthUser> login({
    required String username,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> getCached() {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> sync() {
    throw UnimplementedError();
  }
}
