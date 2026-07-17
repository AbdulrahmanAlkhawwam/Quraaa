import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/features/settings/domain/entities/appearance_option.dart';
import 'package:quraaa/features/settings/domain/entities/language_option.dart';
import 'package:quraaa/features/settings/domain/entities/notification_setting.dart';
import 'package:quraaa/features/settings/domain/entities/settings_section.dart';
import 'package:quraaa/features/settings/domain/entities/settings_tab.dart';
import 'package:quraaa/features/settings/domain/use_cases/get_activity_sections_use_case.dart';
import 'package:quraaa/features/settings/domain/use_cases/get_appearance_options_use_case.dart';
import 'package:quraaa/features/settings/domain/use_cases/get_badges_sections_use_case.dart';
import 'package:quraaa/features/settings/domain/use_cases/get_language_options_use_case.dart';
import 'package:quraaa/features/settings/domain/use_cases/get_library_sections_use_case.dart';
import 'package:quraaa/features/settings/domain/use_cases/get_notification_settings_use_case.dart';
import 'package:quraaa/features/settings/domain/use_cases/get_profile_sections_use_case.dart';
import 'package:quraaa/features/settings/domain/use_cases/get_settings_sections_use_case.dart';
import 'package:quraaa/features/settings/domain/use_cases/get_settings_tabs_use_case.dart';
import 'package:quraaa/features/settings/domain/use_cases/update_appearance_option_use_case.dart';
import 'package:quraaa/features/settings/domain/use_cases/update_language_option_use_case.dart';
import 'package:quraaa/features/settings/domain/use_cases/update_notification_setting_use_case.dart';
import 'package:quraaa/features/settings/presentation/bloc/settings_bloc.dart';

import '../../../../mocks/mock_classes.dart';

void main() {
  group('SettingsBloc', () {
    late MockSettingsRepository repository;
    late MockStorageService storageService;
    late SettingsBloc bloc;

    setUp(() {
      repository = MockSettingsRepository();
      storageService = MockStorageService();
      when(() => storageService.clearAll()).thenAnswer((_) async => true);

      when(() => repository.getSettingsTabs()).thenAnswer(
        (_) async => const Success<List<SettingsTab>>(<SettingsTab>[
          SettingsTab(id: 'profile', labelKey: 'profile', iconKey: 'user'),
          SettingsTab(id: 'settings', labelKey: 'settings', iconKey: 'settings'),
        ]),
      );
      when(() => repository.getProfileSections()).thenAnswer(
        (_) async => const Success<List<SettingsSection>>(<SettingsSection>[]),
      );
      when(() => repository.getSettingsSections()).thenAnswer(
        (_) async => const Success<List<SettingsSection>>(<SettingsSection>[]),
      );
      when(() => repository.getLibrarySections()).thenAnswer(
        (_) async => const Success<List<SettingsSection>>(<SettingsSection>[]),
      );
      when(() => repository.getBadgesSections()).thenAnswer(
        (_) async => const Success<List<SettingsSection>>(<SettingsSection>[]),
      );
      when(() => repository.getActivitySections()).thenAnswer(
        (_) async => const Success<List<SettingsSection>>(<SettingsSection>[]),
      );
      when(() => repository.getAppearanceOptions()).thenAnswer(
        (_) async => const Success<List<AppearanceOption>>(<AppearanceOption>[]),
      );
      when(() => repository.getNotificationSettings()).thenAnswer(
        (_) async => const Success<List<NotificationSetting>>(<NotificationSetting>[]),
      );
      when(() => repository.getLanguageOptions()).thenAnswer(
        (_) async => const Success<List<LanguageOption>>(<LanguageOption>[]),
      );

      bloc = SettingsBloc(
        getTabs: GetSettingsTabsUseCase(repository),
        getProfileSections: GetProfileSectionsUseCase(repository),
        getSettingsSections: GetSettingsSectionsUseCase(repository),
        getLibrarySections: GetLibrarySectionsUseCase(repository),
        getBadgesSections: GetBadgesSectionsUseCase(repository),
        getActivitySections: GetActivitySectionsUseCase(repository),
        getAppearanceOptions: GetAppearanceOptionsUseCase(repository),
        getNotificationSettings: GetNotificationSettingsUseCase(repository),
        getLanguageOptions: GetLanguageOptionsUseCase(repository),
        updateAppearance: UpdateAppearanceOptionUseCase(repository),
        updateNotification: UpdateNotificationSettingUseCase(repository),
        updateLanguage: UpdateLanguageOptionUseCase(repository),
        storageService: storageService,
      );
    });

    test('initial state is SettingsInitial', () {
      expect(bloc.state, const SettingsInitial());
    });

    test('emits SettingsLoaded with first tab active after started', () async {
      bloc.add(const SettingsStarted());

      await expectLater(
        bloc.stream,
        emitsInOrder(<dynamic>[
          isA<SettingsLoading>(),
          isA<SettingsLoaded>(),
        ]),
      );

      final SettingsLoaded state = bloc.state as SettingsLoaded;
      expect(state.tabs.length, 2);
      expect(state.activeTab.id, 'profile');
    });

    test('changes active tab', () async {
      bloc.add(const SettingsStarted());
      await bloc.stream.firstWhere((state) => state is SettingsLoaded);

      final SettingsLoaded loaded = bloc.state as SettingsLoaded;
      final SettingsTab settingsTab = loaded.tabs.last;

      bloc.add(SettingsTabChanged(settingsTab));

      await expectLater(
        bloc.stream,
        emits(
          isA<SettingsLoaded>().having(
            (SettingsLoaded s) => s.activeTab.id,
            'activeTab',
            'settings',
          ),
        ),
      );
    });


    test('clears storage and emits logout success after logout requested', () async {
      bloc.add(const SettingsLogoutRequested());

      await expectLater(
        bloc.stream,
        emits(isA<SettingsLogoutSuccess>()),
      );

      verify(() => storageService.clearAll()).called(1);
    });
  });
}
