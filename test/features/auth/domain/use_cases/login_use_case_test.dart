import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/auth/domain/entities/user.dart';
import 'package:quraaa/features/auth/domain/use_cases/login_use_case.dart';

import '../../../../mocks/mock_classes.dart';

void main() {
  late MockAuthRepository repository;
  late LoginUseCase useCase;

  const params = LoginParams(phoneNumber: '+963999111222', password: 'pw');

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  test('forwards the credentials and returns the signed-in user', () async {
    const user = User(id: 'user-1');
    when(
      () => repository.login(phoneNumber: '+963999111222', password: 'pw'),
    ).thenAnswer((_) async => const Right(user));

    expect(await useCase(params), const Right<Failure, User>(user));
  });

  test('passes the repository failure through unchanged', () async {
    const failure = LoginFailure(message: 'wrong password');
    when(
      () => repository.login(phoneNumber: '+963999111222', password: 'pw'),
    ).thenAnswer((_) async => const Left(failure));

    expect(await useCase(params), const Left<Failure, User>(failure));
  });
}
