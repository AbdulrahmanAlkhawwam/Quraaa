import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/settings/domain/entities/library_registration.dart';
import 'package:quraaa/features/settings/domain/repositories/library_registration_repository.dart';
import 'package:quraaa/features/settings/domain/use_cases/request_library_registration_use_case.dart';
import 'package:quraaa/features/settings/presentation/cubit/library_registration_cubit.dart';

class _MockLibraryRegistrationRepository extends Mock
    implements LibraryRegistrationRepository {}

void main() {
  group('LibraryRegistrationCubit', () {
    late _MockLibraryRegistrationRepository repository;
    late LibraryRegistrationCubit cubit;

    final LibraryRegistration registration = LibraryRegistration(
      registrationUrl:
          'https://library.quraa.dev/libraries/register#token=test',
      expiresAtUtc: DateTime.utc(2026, 8, 14, 15, 59, 25),
    );

    setUp(() {
      repository = _MockLibraryRegistrationRepository();
      cubit = LibraryRegistrationCubit(
        RequestLibraryRegistrationUseCase(repository),
      );
    });

    tearDown(() => cubit.close());

    test('emits loading then ready with the registration URL', () async {
      when(
        repository.requestRegistration,
      ).thenAnswer(
        (_) async => Success<LibraryRegistration>(registration),
      );

      final Future<void> expectation = expectLater(
        cubit.stream,
        emitsInOrder(<dynamic>[
          isA<LibraryRegistrationLoading>(),
          isA<LibraryRegistrationReady>().having(
            (LibraryRegistrationReady state) =>
                state.registration.registrationUrl,
            'registrationUrl',
            registration.registrationUrl,
          ),
        ]),
      );

      await cubit.requestRegistration();
      await expectation;

      verify(repository.requestRegistration).called(1);
    });

    test('emits loading then failure when the request fails', () async {
      const UnknownFailure failure = UnknownFailure(message: 'Request failed.');
      when(
        repository.requestRegistration,
      ).thenAnswer(
        (_) async => const ResultFailure<LibraryRegistration>(
          'Request failed.',
          cause: failure,
        ),
      );

      final Future<void> expectation = expectLater(
        cubit.stream,
        emitsInOrder(<dynamic>[
          isA<LibraryRegistrationLoading>(),
          isA<LibraryRegistrationFailure>().having(
            (LibraryRegistrationFailure state) => state.error,
            'error',
            failure,
          ),
        ]),
      );

      await cubit.requestRegistration();
      await expectation;
    });
  });
}
