import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/services/notification_service.dart';
import 'package:quraaa/features/account/account.dart';
import 'package:quraaa/features/home/presentation/bloc/home_bloc.dart';

void main() {
  test('emits loading then loaded when home starts', () async {
    final HomeBloc bloc = HomeBloc(
      loadUserSnapshot: LoadAccountUserSnapshotUseCase(
        const _FakeHomeRepository(
          AccountUserSnapshot(fullName: 'Abdulrahman Alkhawwam'),
        ),
      ),
      notificationService: const _FakeNotificationService(),
    );
    addTearDown(bloc.close);

    bloc.add(const HomeStarted());

    await expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        isA<HomeState>().having(
          (HomeState state) => state.status,
          'status',
          HomeStatus.loading,
        ),
        isA<HomeState>()
            .having(
              (HomeState state) => state.status,
              'status',
              HomeStatus.loaded,
            )
            .having(
              (HomeState state) => state.firstName,
              'firstName',
              'Abdulrahman',
            ),
      ]),
    );
  });

  test('emits failure when loading the user snapshot fails', () async {
    final HomeBloc bloc = HomeBloc(
      loadUserSnapshot: LoadAccountUserSnapshotUseCase(
        const _ThrowingHomeRepository(),
      ),
      notificationService: const _FakeNotificationService(),
    );
    addTearDown(bloc.close);

    bloc.add(const HomeStarted());

    await expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        isA<HomeState>().having(
          (HomeState state) => state.status,
          'status',
          HomeStatus.loading,
        ),
        isA<HomeState>().having(
          (HomeState state) => state.status,
          'status',
          HomeStatus.failure,
        ),
      ]),
    );
  });
}

class _FakeHomeRepository implements AccountRepository {
  const _FakeHomeRepository(this.snapshot);

  final AccountUserSnapshot snapshot;

  @override
  Future<AccountUserSnapshot> loadUserSnapshot() async => snapshot;
}

class _ThrowingHomeRepository implements AccountRepository {
  const _ThrowingHomeRepository();

  @override
  Future<AccountUserSnapshot> loadUserSnapshot() async {
    throw StateError('cannot load user');
  }
}

class _FakeNotificationService implements NotificationService {
  const _FakeNotificationService();

  @override
  Stream<RemoteMessage> get foregroundMessages =>
      Stream<RemoteMessage>.empty();

  @override
  Future<void> handleForegroundMessage(RemoteMessage message) async {}

  @override
  Future<void> initialize({bool shouldRequestPermission = true}) async {}

  @override
  Future<void> requestPermission() async {}
}