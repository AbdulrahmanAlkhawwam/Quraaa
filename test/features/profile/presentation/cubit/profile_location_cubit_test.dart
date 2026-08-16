import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/features/profile/domain/entities/profile.dart';
import 'package:quraaa/features/profile/domain/repositories/profile_repository.dart';
import 'package:quraaa/features/profile/presentation/cubit/profile_location_cubit.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockProfileRepository repository;
  late ProfileLocationCubit cubit;

  const ProfileLocation first = ProfileLocation(
    id: 'first',
    name: 'Home',
    latitude: 33.51,
    longitude: 36.29,
    isDefault: true,
  );
  const ProfileLocation second = ProfileLocation(
    id: 'second',
    name: 'Work',
    latitude: 33.53,
    longitude: 36.31,
  );

  setUp(() {
    repository = _MockProfileRepository();
    cubit = ProfileLocationCubit(repository);
    when(
      () => repository.getLocations(),
    ).thenAnswer((_) async => <ProfileLocation>[first, second]);
  });

  tearDown(() => cubit.close());

  test('changes the favorite location locally without updating the backend',
      () async {
    await cubit.load();

    cubit.setDefault(second);

    expect(
      cubit.state.locations.map((ProfileLocation item) => item.isDefault),
      <bool>[false, true],
    );
    verify(() => repository.getLocations()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
