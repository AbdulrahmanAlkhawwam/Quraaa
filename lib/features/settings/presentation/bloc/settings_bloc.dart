import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/appearance_option.dart';
import '../../domain/entities/language_option.dart';
import '../../domain/entities/notification_setting.dart';
import '../../domain/entities/settings_section.dart';
import '../../domain/entities/settings_tab.dart';
import '../../domain/use_cases/get_activity_sections_use_case.dart';
import '../../domain/use_cases/get_appearance_options_use_case.dart';
import '../../domain/use_cases/get_badges_sections_use_case.dart';
import '../../domain/use_cases/get_language_options_use_case.dart';
import '../../domain/use_cases/get_library_sections_use_case.dart';
import '../../domain/use_cases/get_notification_settings_use_case.dart';
import '../../domain/use_cases/get_profile_sections_use_case.dart';
import '../../domain/use_cases/get_settings_sections_use_case.dart';
import '../../domain/use_cases/get_settings_tabs_use_case.dart';
import '../../domain/use_cases/update_appearance_option_use_case.dart';
import '../../domain/use_cases/update_language_option_use_case.dart';
import '../../domain/use_cases/update_notification_setting_use_case.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

final class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

final class SettingsTabChanged extends SettingsEvent {
  const SettingsTabChanged(this.tab);

  final SettingsTab tab;
}

final class SettingsScrolled extends SettingsEvent {
  const SettingsScrolled(this.offset);

  final double offset;
}

final class SettingsAppearanceSelected extends SettingsEvent {
  const SettingsAppearanceSelected(this.id);

  final String id;
}

final class SettingsNotificationToggled extends SettingsEvent {
  const SettingsNotificationToggled({required this.id, required this.value});

  final String id;
  final bool value;
}

final class SettingsLanguageSelected extends SettingsEvent {
  const SettingsLanguageSelected(this.id);

  final String id;
}

final class SettingsLogoutRequested extends SettingsEvent {
  const SettingsLogoutRequested();
}

sealed class SettingsState {
  const SettingsState();
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.tabs,
    required this.activeTab,
    required this.scrollOffset,
    required this.profileSections,
    required this.settingsSections,
    required this.librarySections,
    required this.badgesSections,
    required this.activitySections,
    required this.appearanceOptions,
    required this.notificationSettings,
    required this.languageOptions,
  });

  final List<SettingsTab> tabs;
  final SettingsTab activeTab;
  final double scrollOffset;
  final List<SettingsSection> profileSections;
  final List<SettingsSection> settingsSections;
  final List<SettingsSection> librarySections;
  final List<SettingsSection> badgesSections;
  final List<SettingsSection> activitySections;
  final List<AppearanceOption> appearanceOptions;
  final List<NotificationSetting> notificationSettings;
  final List<LanguageOption> languageOptions;

  List<SettingsSection> sectionsForTab(SettingsTab tab) {
    return switch (tab.id) {
      'profile' => profileSections,
      'settings' => settingsSections,
      'library' => librarySections,
      'badges' => badgesSections,
      'activity' => activitySections,
      _ => <SettingsSection>[],
    };
  }

  SettingsLoaded copyWith({
    SettingsTab? activeTab,
    double? scrollOffset,
    List<AppearanceOption>? appearanceOptions,
    List<NotificationSetting>? notificationSettings,
    List<LanguageOption>? languageOptions,
  }) {
    return SettingsLoaded(
      tabs: tabs,
      activeTab: activeTab ?? this.activeTab,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      profileSections: profileSections,
      settingsSections: settingsSections,
      librarySections: librarySections,
      badgesSections: badgesSections,
      activitySections: activitySections,
      appearanceOptions: appearanceOptions ?? this.appearanceOptions,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      languageOptions: languageOptions ?? this.languageOptions,
    );
  }
}

final class SettingsFailure extends SettingsState {
  const SettingsFailure(this.message);

  final String message;
}

final class SettingsLogoutSuccess extends SettingsState {
  const SettingsLogoutSuccess();
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required GetSettingsTabsUseCase getTabs,
    required GetProfileSectionsUseCase getProfileSections,
    required GetSettingsSectionsUseCase getSettingsSections,
    required GetLibrarySectionsUseCase getLibrarySections,
    required GetBadgesSectionsUseCase getBadgesSections,
    required GetActivitySectionsUseCase getActivitySections,
    required GetAppearanceOptionsUseCase getAppearanceOptions,
    required GetNotificationSettingsUseCase getNotificationSettings,
    required GetLanguageOptionsUseCase getLanguageOptions,
    required UpdateAppearanceOptionUseCase updateAppearance,
    required UpdateNotificationSettingUseCase updateNotification,
    required UpdateLanguageOptionUseCase updateLanguage,
    required StorageService storageService,
  })  : _getTabs = getTabs,
        _getProfileSections = getProfileSections,
        _getSettingsSections = getSettingsSections,
        _getLibrarySections = getLibrarySections,
        _getBadgesSections = getBadgesSections,
        _getActivitySections = getActivitySections,
        _getAppearanceOptions = getAppearanceOptions,
        _getNotificationSettings = getNotificationSettings,
        _getLanguageOptions = getLanguageOptions,
        _updateAppearance = updateAppearance,
        _updateNotification = updateNotification,
        _updateLanguage = updateLanguage,
        _storageService = storageService,
        super(const SettingsInitial()) {
    on<SettingsStarted>(_onStarted);
    on<SettingsTabChanged>(_onTabChanged);
    on<SettingsScrolled>(_onScrolled);
    on<SettingsAppearanceSelected>(_onAppearanceSelected);
    on<SettingsNotificationToggled>(_onNotificationToggled);
    on<SettingsLanguageSelected>(_onLanguageSelected);
    on<SettingsLogoutRequested>(_onLogoutRequested);
  }

  final GetSettingsTabsUseCase _getTabs;
  final GetProfileSectionsUseCase _getProfileSections;
  final GetSettingsSectionsUseCase _getSettingsSections;
  final GetLibrarySectionsUseCase _getLibrarySections;
  final GetBadgesSectionsUseCase _getBadgesSections;
  final GetActivitySectionsUseCase _getActivitySections;
  final GetAppearanceOptionsUseCase _getAppearanceOptions;
  final GetNotificationSettingsUseCase _getNotificationSettings;
  final GetLanguageOptionsUseCase _getLanguageOptions;
  final UpdateAppearanceOptionUseCase _updateAppearance;
  final UpdateNotificationSettingUseCase _updateNotification;
  final UpdateLanguageOptionUseCase _updateLanguage;
  final StorageService _storageService;

  Future<void> _onStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final tabsResult = await _getTabs(const NoParams());
    final profileSectionsResult = await _getProfileSections(const NoParams());
    final settingsSectionsResult = await _getSettingsSections(const NoParams());
    final librarySectionsResult = await _getLibrarySections(const NoParams());
    final badgesSectionsResult = await _getBadgesSections(const NoParams());
    final activitySectionsResult = await _getActivitySections(const NoParams());
    final appearanceResult = await _getAppearanceOptions(const NoParams());
    final notificationResult = await _getNotificationSettings(const NoParams());
    final languageResult = await _getLanguageOptions(const NoParams());

    final List<SettingsTab> tabs = switch (tabsResult) {
      Success<List<SettingsTab>>(value: final value) => value,
      ResultFailure<List<SettingsTab>>() => <SettingsTab>[],
    };

    final List<SettingsSection> profileSections = switch (profileSectionsResult) {
      Success<List<SettingsSection>>(value: final value) => value,
      ResultFailure<List<SettingsSection>>() => <SettingsSection>[],
    };

    final List<SettingsSection> settingsSections = switch (
        settingsSectionsResult) {
      Success<List<SettingsSection>>(value: final value) => value,
      ResultFailure<List<SettingsSection>>() => <SettingsSection>[],
    };

    final List<SettingsSection> librarySections = switch (librarySectionsResult) {
      Success<List<SettingsSection>>(value: final value) => value,
      ResultFailure<List<SettingsSection>>() => <SettingsSection>[],
    };

    final List<SettingsSection> badgesSections = switch (badgesSectionsResult) {
      Success<List<SettingsSection>>(value: final value) => value,
      ResultFailure<List<SettingsSection>>() => <SettingsSection>[],
    };

    final List<SettingsSection> activitySections = switch (
        activitySectionsResult) {
      Success<List<SettingsSection>>(value: final value) => value,
      ResultFailure<List<SettingsSection>>() => <SettingsSection>[],
    };

    final List<AppearanceOption> appearanceOptions = switch (appearanceResult) {
      Success<List<AppearanceOption>>(value: final value) => value,
      ResultFailure<List<AppearanceOption>>() => <AppearanceOption>[],
    };

    final List<NotificationSetting> notificationSettings = switch (
        notificationResult) {
      Success<List<NotificationSetting>>(value: final value) => value,
      ResultFailure<List<NotificationSetting>>() => <NotificationSetting>[],
    };

    final List<LanguageOption> languageOptions = switch (languageResult) {
      Success<List<LanguageOption>>(value: final value) => value,
      ResultFailure<List<LanguageOption>>() => <LanguageOption>[],
    };

    if (tabs.isEmpty) {
      emit(const SettingsFailure(LocalizationConstants.settingsLoadFailureKey));
      return;
    }

    emit(
      SettingsLoaded(
        tabs: tabs,
        activeTab: tabs.first,
        scrollOffset: 0,
        profileSections: profileSections,
        settingsSections: settingsSections,
        librarySections: librarySections,
        badgesSections: badgesSections,
        activitySections: activitySections,
        appearanceOptions: appearanceOptions,
        notificationSettings: notificationSettings,
        languageOptions: languageOptions,
      ),
    );
  }

  void _onTabChanged(
    SettingsTabChanged event,
    Emitter<SettingsState> emit,
  ) {
    final SettingsState state = this.state;
    if (state is! SettingsLoaded) {
      return;
    }

    emit(state.copyWith(activeTab: event.tab));
  }

  void _onScrolled(
    SettingsScrolled event,
    Emitter<SettingsState> emit,
  ) {
    final SettingsState state = this.state;
    if (state is! SettingsLoaded) {
      return;
    }

    emit(state.copyWith(scrollOffset: event.offset));
  }

  Future<void> _onAppearanceSelected(
    SettingsAppearanceSelected event,
    Emitter<SettingsState> emit,
  ) async {
    final SettingsState state = this.state;
    if (state is! SettingsLoaded) {
      return;
    }

    final result = await _updateAppearance(
      UpdateAppearanceOptionParams(id: event.id),
    );

    final List<AppearanceOption> options = switch (result) {
      Success<List<AppearanceOption>>(value: final value) => value,
      ResultFailure<List<AppearanceOption>>() => state.appearanceOptions,
    };

    emit(state.copyWith(appearanceOptions: options));
  }

  Future<void> _onNotificationToggled(
    SettingsNotificationToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final SettingsState state = this.state;
    if (state is! SettingsLoaded) {
      return;
    }

    final result = await _updateNotification(
      UpdateNotificationSettingParams(
        id: event.id,
        value: event.value,
      ),
    );

    final List<NotificationSetting> settings = switch (result) {
      Success<List<NotificationSetting>>(value: final value) => value,
      ResultFailure<List<NotificationSetting>>() => state.notificationSettings,
    };

    emit(state.copyWith(notificationSettings: settings));
  }

  Future<void> _onLanguageSelected(
    SettingsLanguageSelected event,
    Emitter<SettingsState> emit,
  ) async {
    final SettingsState state = this.state;
    if (state is! SettingsLoaded) {
      return;
    }

    final result = await _updateLanguage(
      UpdateLanguageOptionParams(id: event.id),
    );

    final List<LanguageOption> options = switch (result) {
      Success<List<LanguageOption>>(value: final value) => value,
      ResultFailure<List<LanguageOption>>() => state.languageOptions,
    };

    emit(state.copyWith(languageOptions: options));
  }

  Future<void> _onLogoutRequested(
    SettingsLogoutRequested event,
    Emitter<SettingsState> emit,
  ) async {
    await _storageService.clearAll();
    emit(const SettingsLogoutSuccess());
  }
}
