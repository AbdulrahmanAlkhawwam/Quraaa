import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/gender_selection.dart';
import '../../domain/entities/onboarding_draft.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../data_sources/onboarding_local_data_source.dart';
import '../data_sources/onboarding_remote_data_source.dart';
import '../models/category_model.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final OnboardingLocalDataSource _localDataSource;
  final OnboardingRemoteDataSource _remoteDataSource;

  @override
  FutureEither<OnboardingDraft> loadState() =>
      _guard(_localDataSource.loadState);

  @override
  FutureEither<Unit> saveBirthDate({
    required int year,
    required int month,
    required int day,
  }) {
    return _guardUnit(
      () => _localDataSource.saveBirthDate(year: year, month: month, day: day),
    );
  }

  @override
  FutureEither<Unit> saveGender(GenderSelection gender) =>
      _guardUnit(() => _localDataSource.saveGender(gender));

  @override
  FutureEither<Unit> saveCategoryIds(List<String>? categoryIds) =>
      _guardUnit(() => _localDataSource.saveCategoryIds(categoryIds));

  @override
  FutureEither<List<Category>> getCategories() {
    return _guard(() async {
      // The cache is filled on first fetch and answers every later call.
      final List<CategoryModel>? cached = await _localDataSource
          .getCachedCategories();
      if (cached != null && cached.isNotEmpty) return cached;

      final List<CategoryModel> fresh = await _remoteDataSource.getCategories();
      await _localDataSource.saveCachedCategories(fresh);
      return fresh;
    });
  }

  @override
  FutureEither<Unit> completeOnboarding() =>
      _guardUnit(_localDataSource.completeOnboarding);

  @override
  FutureEither<Unit> resetCompletion() =>
      _guardUnit(_localDataSource.resetCompletion);

  @override
  FutureEither<bool> isCompleted() {
    return _guard(() async => (await _localDataSource.loadState()).completed);
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  FutureEither<Unit> _guardUnit(Future<void> Function() body) =>
      _guard(() async {
        await body();
        return unit;
      });
}
