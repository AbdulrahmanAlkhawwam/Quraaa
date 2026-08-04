import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/architecture/use_case.dart';
import 'package:quraaa/features/account/account.dart';

void main() {
  test('loads the account user snapshot from the repository', () async {
    const AccountUserSnapshot snapshot = AccountUserSnapshot(
      fullName: 'Test User',
      profileImage: '/tmp/avatar.png',
    );
    final LoadAccountUserSnapshotUseCase useCase =
        LoadAccountUserSnapshotUseCase(_FakeAccountRepository(snapshot));

    final AccountUserSnapshot result = await useCase(const NoParams());

    expect(result.fullName, snapshot.fullName);
    expect(result.firstName, 'Test');
    expect(result.profileImage, snapshot.profileImage);
  });
}

class _FakeAccountRepository implements AccountRepository {
  const _FakeAccountRepository(this.snapshot);

  final AccountUserSnapshot snapshot;

  @override
  Future<AccountUserSnapshot> loadUserSnapshot() async => snapshot;
}