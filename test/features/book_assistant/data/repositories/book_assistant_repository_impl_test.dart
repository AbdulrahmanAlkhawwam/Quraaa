import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/book_assistant/data/data_sources/book_assistant_remote_data_source.dart';
import 'package:quraaa/features/book_assistant/data/models/book_summary_model.dart';
import 'package:quraaa/features/book_assistant/data/repositories/book_assistant_repository_impl.dart';

class _MockRemote extends Mock implements BookAssistantRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late BookAssistantRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = BookAssistantRepositoryImpl(remote);
  });

  test('summarize returns the summary text', () async {
    when(
      () => remote.summarize(purchaseId: 'purchase-1'),
    ).thenAnswer((_) async => const BookSummaryModel(summary: 'In short...'));

    expect(
      await repository.summarize(purchaseId: 'purchase-1'),
      const Right<Failure, String>('In short...'),
    );
  });

  test('a backend error becomes a typed failure', () async {
    when(
      () => remote.summarize(purchaseId: 'purchase-1'),
    ).thenThrow(const TooManyRequestsException(message: 'slow down'));

    final Either<Failure, String> result = await repository.summarize(
      purchaseId: 'purchase-1',
    );

    expect(result.getLeft().toNullable(), isA<TooManyRequestsFailure>());
  });

  test('explain reaches the backend', () async {
    when(
      () => remote.explain(purchaseId: 'purchase-1', selectedText: 'nahw'),
    ).thenAnswer((_) async => 'Grammar.');

    expect(
      await repository.explain(purchaseId: 'purchase-1', selectedText: 'nahw'),
      const Right<Failure, String>('Grammar.'),
    );
  });
}
