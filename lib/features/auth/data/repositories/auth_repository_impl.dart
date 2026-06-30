import '../../../../core/architecture/base_repository.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth_tokens_model.dart';

class AuthRepositoryImpl extends BaseRepository<AuthUser>
    implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthUser> login({
    required String username,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthTokens> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    required int gender,
    required String dateOfBirth,
    required List<String> interests,
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
    return AuthTokensModel.fromJson(response);
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
