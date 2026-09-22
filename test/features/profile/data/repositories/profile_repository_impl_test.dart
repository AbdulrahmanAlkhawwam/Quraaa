import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:quraaa/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:quraaa/features/profile/data/models/profile_location_model.dart';
import 'package:quraaa/features/profile/data/models/profile_model.dart';
import 'package:quraaa/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:quraaa/features/profile/domain/entities/profile.dart';

class _MockRemote extends Mock implements ProfileRemoteDataSource {}

class _MockLocal extends Mock implements ProfileLocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late ProfileRepositoryImpl repository;

  const ProfileModel remoteProfile = ProfileModel(
    userId: 'user-1',
    firstName: 'Nour',
  );
  const ProfileLocationModel home = ProfileLocationModel(
    id: 'home',
    latitude: 33.51,
    longitude: 36.29,
    isDefault: true,
  );

  setUpAll(() {
    registerFallbackValue(const ProfileModel());
    registerFallbackValue(const ProfileLocation(latitude: 0, longitude: 0));
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    repository = ProfileRepositoryImpl(remote, local);
    when(() => local.getCachedProfile()).thenAnswer((_) async => null);
    when(() => local.cacheProfile(any())).thenAnswer((_) async {});
  });

  group('getMyProfile', () {
    test('caches the remote profile and returns it', () async {
      when(() => remote.getMyProfile()).thenAnswer((_) async => remoteProfile);

      final Either<Failure, Profile> result = await repository.getMyProfile();

      expect(result, const Right<Failure, Profile>(remoteProfile));
      verify(() => local.cacheProfile(remoteProfile)).called(1);
    });

    test('returns the mapped failure and caches nothing on 401', () async {
      when(
        () => remote.getMyProfile(),
      ).thenThrow(const UnauthorizedException(message: 'expired'));

      final Either<Failure, Profile> result = await repository.getMyProfile();

      expect(result.getLeft().toNullable(), isA<UnauthorizedFailure>());
      verifyNever(() => local.cacheProfile(any()));
    });
  });

  group('locations', () {
    test('setDefault skips the backend call for an unsaved location', () async {
      when(
        () => remote.getLocations(),
      ).thenAnswer((_) async => <ProfileLocationModel>[home]);

      final Either<Failure, List<ProfileLocation>> result = await repository
          .setDefaultLocation(const ProfileLocation(latitude: 1, longitude: 1));

      expect(result.getOrElse((_) => fail('expected Right')), <ProfileLocation>[
        home,
      ]);
      verifyNever(() => remote.setDefaultLocation(any()));
    });

    test('a failed mutation returns a failure without re-fetching', () async {
      when(
        () => remote.deleteLocation(any()),
      ).thenThrow(const NotFoundException(message: 'gone'));

      final Either<Failure, List<ProfileLocation>> result = await repository
          .deleteLocation(home);

      expect(result.getLeft().toNullable(), isA<NotFoundFailure>());
      verifyNever(() => remote.getLocations());
    });
  });
}
