import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/core/architecture/use_case.dart';
import 'package:quraaa/features/settings/domain/entities/settings_tab.dart';
import 'package:quraaa/features/settings/domain/use_cases/get_settings_tabs_use_case.dart';

import '../../../../mocks/mock_classes.dart';

void main() {
  group('GetSettingsTabsUseCase', () {
    late MockSettingsRepository repository;
    late GetSettingsTabsUseCase useCase;

    setUp(() {
      repository = MockSettingsRepository();
      useCase = GetSettingsTabsUseCase(repository);
    });

    test('returns five settings tabs', () async {
      const List<SettingsTab> expectedTabs = <SettingsTab>[
        SettingsTab(id: 'profile', labelKey: 'profile', iconKey: 'user'),
        SettingsTab(id: 'library', labelKey: 'library', iconKey: 'library'),
      ];

      when(() => repository.getSettingsTabs())
          .thenAnswer((_) async => const Success<List<SettingsTab>>(expectedTabs));

      final Result<List<SettingsTab>> result = await useCase(const NoParams());

      expect(result, isA<Success<List<SettingsTab>>>());
      expect((result as Success<List<SettingsTab>>).value.length, 2);
      verify(() => repository.getSettingsTabs()).called(1);
    });
  });
}
