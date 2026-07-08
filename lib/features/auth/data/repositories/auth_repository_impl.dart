import '../../../../core/architecture/base_repository.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
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
      return _mapError(error);
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
      return _mapError(error);
    }
  }

  @override
  Future<Result<User>> refreshToken({required String refreshToken}) async {
    try {
      final response = await _remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );
      return Success(AuthMapper.fromJson(response));
    } catch (error) {
      return _mapError(error);
    }
  }

  @override
  Future<Result<User>> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final response = await _remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        code: code,
      );
      return Success(AuthMapper.fromJson(response));
    } catch (error) {
      return _mapError(error);
    }
  }

  @override
  Future<Result<bool>> forgotPassword({required String phoneNumber}) async {
    try {
      await _remoteDataSource.forgotPassword(phoneNumber: phoneNumber);
      return const Success(true);
    } catch (error) {
      return _mapError(error);
    }
  }

  @override
  Future<Result<bool>> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        phoneNumber: phoneNumber,
        code: code,
        newPassword: newPassword,
      );
      return const Success(true);
    } catch (error) {
      return _mapError(error);
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

  ResultFailure<T> _mapError<T>(Object error) {
    final Failure failure = ErrorMapper.map(error);
    return ResultFailure(failure.message, cause: failure);
  }
}
