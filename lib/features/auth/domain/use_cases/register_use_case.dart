import '../../../../core/architecture/use_case.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  const RegisterParams({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.password,
    this.gender,
    this.dateOfBirth,
    this.categoryIds,
  });

  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? password;
  final int? gender;
  final String? dateOfBirth;
  final List<String>? categoryIds;
}

class RegisterUseCase extends UseCase<User, RegisterParams> {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<User> call(RegisterParams params) {
    return _repository.register(
      firstName: params.firstName,
      lastName: params.lastName,
      phoneNumber: params.phoneNumber,
      password: params.password,
      gender: params.gender,
      dateOfBirth: params.dateOfBirth,
      categoryIds: params.categoryIds,
    );
  }
}
