import '../../../../core/architecture/base_repository.dart';
import '../../../../core/architecture/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';

class AuthRepositoryImpl extends BaseRepository<User>
    implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Result<User>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      return Success(AuthMapper.fromJson(response));
    } catch (error) {
      return ResultFailure(_mapError(error));
    }
  }

  @override
  Future<Result<User>> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? categoryIds,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        password: password,
        gender: gender,
        dateOfBirth: dateOfBirth,
        categoryIds: categoryIds,
      );
      return Success(AuthMapper.fromJson(response));
    } catch (error) {
      return ResultFailure(_mapError(error));
    }
  }

  @override
  Future<Result<User>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );
      return Success(AuthMapper.fromJson(response));
    } catch (error) {
      return ResultFailure(_mapError(error));
    }
  }

  @override
  Future<User> getCached() {
    throw UnimplementedError();
  }

  @override
  Future<User> sync() {
    throw UnimplementedError();
  }

  String _mapError(Object error) {
    return error is Exception ? error.toString() : 'Unexpected error';
  }
}
