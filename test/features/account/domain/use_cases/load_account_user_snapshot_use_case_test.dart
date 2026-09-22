import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/core/use_cases/use_case.dart';
import 'package:quraaa/features/account/account.dart';

void main() {
  test('loads the account user snapshot from the repository', () async {
    const AccountUserSnapshot snapshot = AccountUserSnapshot(
      fullName: 'Test User',
      profileImage: '/tmp/avatar.png',
    );
    final LoadAccountUserSnapshotUseCase useCase =
        LoadAccountUserSnapshotUseCase(
          const _FakeAccountRepository(Right(snapshot)),
        );

    final AccountUserSnapshot result = (await useCase()).getOrElse(
      (_) => fail('expected Right'),
    );

    expect(result.fullName, snapshot.fullName);
    expect(result.firstName, 'Test');
    expect(result.profileImage, snapshot.profileImage);
  });

  test('passes the repository failure through', () async {
    final LoadAccountUserSnapshotUseCase useCase =
        LoadAccountUserSnapshotUseCase(
          const _FakeAccountRepository(Left(CacheReadFailure())),
        );

    expect((await useCase()).getLeft().toNullable(), isA<CacheReadFailure>());
  });
}

class _FakeAccountRepository implements AccountRepository {
  const _FakeAccountRepository(this.result);

  final Either<Failure, AccountUserSnapshot> result;

  @override
  FutureEither<AccountUserSnapshot> loadUserSnapshot() async => result;
}
