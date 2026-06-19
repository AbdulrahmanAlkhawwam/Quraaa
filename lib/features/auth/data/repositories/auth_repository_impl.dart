import '../../../../core/architecture/base_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl extends BaseRepository<User>
    implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<User> login({
    required String username,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<User> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? interests,
  }) async {
    final Map<String, Object?> response = await _remoteDataSource.register(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      password: password,
      gender: gender,
      dateOfBirth: dateOfBirth,
      interests: interests,
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
