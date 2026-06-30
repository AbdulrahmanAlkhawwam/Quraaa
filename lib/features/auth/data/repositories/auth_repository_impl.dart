import '../../../../core/architecture/base_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';

class AuthRepositoryImpl extends BaseRepository<User>
    implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<User> login({
    required String phoneNumber,
    required String password,
  }) async {
    final Map<String, Object?> response = await _remoteDataSource.login(
      phoneNumber: phoneNumber,
      password: password,
    );
    return AuthMapper.fromJson(response);
  }

  @override
  Future<User> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? categoryIds,
  }) async {
    final Map<String, Object?> response = await _remoteDataSource.register(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      password: password,
      gender: gender,
      dateOfBirth: dateOfBirth,
      categoryIds: categoryIds,
    );
    return AuthMapper.fromJson(response);
  }

  @override
  Future<User> refreshToken({
    required String refreshToken,
  }) async {
    final Map<String, Object?> response = await _remoteDataSource.refreshToken(
      refreshToken: refreshToken,
    );
    return AuthMapper.fromJson(response);
  }

  @override
  Future<User> getCached() {
    throw UnimplementedError();
  }

  @override
  Future<User> sync() {
    throw UnimplementedError();
  }
}
