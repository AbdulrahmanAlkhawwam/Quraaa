import '../../../../core/architecture/result.dart';
import '../../domain/entities/appearance_option.dart';
import '../../domain/entities/language_option.dart';
import '../../domain/entities/notification_setting.dart';
import '../../domain/entities/settings_section.dart';
import '../../domain/entities/settings_tab.dart';
import '../../domain/repositories/settings_repository.dart';

/// Dummy implementation of [SettingsRepository].
///
/// All settings are placeholders and do not affect the application state.
/// This implementation can later be replaced by one that reads from and
/// writes to persistent storage.
class SettingsRepositoryImpl extends SettingsRepository {
  const SettingsRepositoryImpl();

  static const List<SettingsTab> _tabs = <SettingsTab>[
    SettingsTab(id: 'profile', labelKey: 'settings.tabs.profile', iconKey: 'user'),
    SettingsTab(id: 'library', labelKey: 'settings.tabs.library', iconKey: 'library'),
    SettingsTab(id: 'badges', labelKey: 'settings.tabs.badges', iconKey: 'trophy'),
    SettingsTab(id: 'activity', labelKey: 'settings.tabs.activity', iconKey: 'clock'),
    SettingsTab(id: 'settings', labelKey: 'settings.tabs.settings', iconKey: 'settings'),
  ];

  static const List<SettingsSection> _profileSections = <SettingsSection>[
    SettingsSection(
      id: 'my_personal_information',
      labelKey: 'settings.profile.myPersonalInformation',
      action: SettingsSectionAction.navigate,
    ),
    SettingsSection(
      id: 'my_locations',
      labelKey: 'settings.profile.myLocations',
      action: SettingsSectionAction.navigate,
    ),
    SettingsSection(
      id: 'payment_information',
      labelKey: 'settings.profile.paymentInformation',
      action: SettingsSectionAction.navigate,
    ),
    SettingsSection(
      id: 'my_personal_files',
      labelKey: 'settings.profile.myPersonalFiles',
      action: SettingsSectionAction.navigate,
    ),
    SettingsSection(
      id: 'my_badges',
      labelKey: 'settings.profile.myBadges',
      action: SettingsSectionAction.navigate,
    ),
    SettingsSection(
      id: 'account_type',
      labelKey: 'settings.profile.accountType',
      action: SettingsSectionAction.navigate,
    ),
    SettingsSection(
      id: 'change_password',
      labelKey: 'settings.profile.changePassword',
      action: SettingsSectionAction.navigate,
    ),
  ];

  static const List<SettingsSection> _settingsSections = <SettingsSection>[
    SettingsSection(
      id: 'appearance',
      labelKey: 'settings.settingsSections.appearance',
      action: SettingsSectionAction.bottomSheet,
      target: 'appearance',
    ),
    SettingsSection(
      id: 'notification_management',
      labelKey: 'settings.settingsSections.notificationManagement',
      action: SettingsSectionAction.bottomSheet,
      target: 'notification',
    ),
    SettingsSection(
      id: 'security_manage',
      labelKey: 'settings.settingsSections.securityManage',
      action: SettingsSectionAction.bottomSheet,
      target: 'security',
    ),
    SettingsSection(
      id: 'languages',
      labelKey: 'settings.settingsSections.languages',
      action: SettingsSectionAction.bottomSheet,
      target: 'language',
    ),
  ];

  static const List<SettingsSection> _librarySections = <SettingsSection>[
    SettingsSection(
      id: 'my_books',
      labelKey: 'settings.library.myBooks',
      action: SettingsSectionAction.navigate,
    ),
    SettingsSection(
      id: 'downloads',
      labelKey: 'settings.library.downloads',
      action: SettingsSectionAction.navigate,
    ),
    SettingsSection(
      id: 'wishlist',
      labelKey: 'settings.library.wishlist',
      action: SettingsSectionAction.navigate,
    ),
    SettingsSection(
      id: 'collections',
      labelKey: 'settings.library.collections',
      action: SettingsSectionAction.navigate,
    ),
  ];

  static const List<SettingsSection> _badgesSections = <SettingsSection>[
    SettingsSection(
      id: 'recent_badges',
      labelKey: 'settings.badges.recentBadges',
      action: SettingsSectionAction.navigate,
    ),
    SettingsSection(
      id: 'achievement_levels',
      labelKey: 'settings.badges.achievementLevels',
      action: SettingsSectionAction.navigate,
    ),
  ];

  static const List<SettingsSection> _activitySections = <SettingsSection>[
    SettingsSection(
      id: 'reading_time',
      labelKey: 'settings.activity.readingTime',
      action: SettingsSectionAction.navigate,
    ),
    SettingsSection(
      id: 'last_opened_books',
      labelKey: 'settings.activity.lastOpenedBooks',
      action: SettingsSectionAction.navigate,
    ),
  ];

  static final List<AppearanceOption> _appearanceOptions = <AppearanceOption>[
    const AppearanceOption(
      id: 'light',
      labelKey: 'settings.appearance.lightMode',
      mode: AppearanceMode.light,
      selected: false,
    ),
    const AppearanceOption(
      id: 'dark',
      labelKey: 'settings.appearance.darkMode',
      mode: AppearanceMode.dark,
      selected: false,
    ),
    const AppearanceOption(
      id: 'system',
      labelKey: 'settings.appearance.deviceSystem',
      mode: AppearanceMode.system,
      selected: true,
    ),
  ];

  static final List<NotificationSetting> _notificationSettings =
      <NotificationSetting>[
    const NotificationSetting(
      id: 'new_update',
      labelKey: 'settings.notification.newUpdate',
      value: true,
    ),
    const NotificationSetting(
      id: 'ads',
      labelKey: 'settings.notification.ads',
      value: false,
    ),
    const NotificationSetting(
      id: 'payment',
      labelKey: 'settings.notification.payment',
      value: true,
    ),
    const NotificationSetting(
      id: 'new_book_version',
      labelKey: 'settings.notification.newBookVersion',
      value: true,
    ),
    const NotificationSetting(
      id: 'finish_book',
      labelKey: 'settings.notification.finishBook',
      value: true,
    ),
    const NotificationSetting(
      id: 'get_new_badge',
      labelKey: 'settings.notification.getNewBadge',
      value: false,
    ),
    const NotificationSetting(
      id: 'upgrade_level',
      labelKey: 'settings.notification.upgradeLevel',
      value: true,
    ),
  ];

  static final List<LanguageOption> _languageOptions = <LanguageOption>[
    const LanguageOption(
      id: 'en',
      labelKey: 'settings.language.english',
      languageCode: 'en',
      selected: true,
    ),
    const LanguageOption(
      id: 'ar',
      labelKey: 'settings.language.arabic',
      languageCode: 'ar',
      selected: false,
    ),
    const LanguageOption(
      id: 'es',
      labelKey: 'settings.language.spanish',
      languageCode: 'es',
      selected: false,
    ),
    const LanguageOption(
      id: 'fr',
      labelKey: 'settings.language.france',
      languageCode: 'fr',
      selected: false,
    ),
    const LanguageOption(
      id: 'de',
      labelKey: 'settings.language.germany',
      languageCode: 'de',
      selected: false,
    ),
  ];

  @override
  Future<Result<List<SettingsTab>>> getSettingsTabs() async {
    return Success<List<SettingsTab>>(List<SettingsTab>.unmodifiable(_tabs));
  }

  @override
  Future<Result<List<SettingsSection>>> getProfileSections() async {
    return Success<List<SettingsSection>>(
      List<SettingsSection>.unmodifiable(_profileSections),
    );
  }

  @override
  Future<Result<List<SettingsSection>>> getSettingsSections() async {
    return Success<List<SettingsSection>>(
      List<SettingsSection>.unmodifiable(_settingsSections),
    );
  }

  @override
  Future<Result<List<SettingsSection>>> getLibrarySections() async {
    return Success<List<SettingsSection>>(
      List<SettingsSection>.unmodifiable(_librarySections),
    );
  }

  @override
  Future<Result<List<SettingsSection>>> getBadgesSections() async {
    return Success<List<SettingsSection>>(
      List<SettingsSection>.unmodifiable(_badgesSections),
    );
  }

  @override
  Future<Result<List<SettingsSection>>> getActivitySections() async {
    return Success<List<SettingsSection>>(
      List<SettingsSection>.unmodifiable(_activitySections),
    );
  }

  @override
  Future<Result<List<AppearanceOption>>> getAppearanceOptions() async {
    return Success<List<AppearanceOption>>(
      List<AppearanceOption>.unmodifiable(_appearanceOptions),
    );
  }

  @override
  Future<Result<List<NotificationSetting>>> getNotificationSettings() async {
    return Success<List<NotificationSetting>>(
      List<NotificationSetting>.unmodifiable(_notificationSettings),
    );
  }

  @override
  Future<Result<List<LanguageOption>>> getLanguageOptions() async {
    return Success<List<LanguageOption>>(
      List<LanguageOption>.unmodifiable(_languageOptions),
    );
  }

  @override
  Future<Result<List<AppearanceOption>>> updateAppearanceOption(String id) async {
    final List<AppearanceOption> updated = _appearanceOptions
        .map(
          (AppearanceOption option) => option.copyWith(
            selected: option.id == id,
          ),
        )
        .toList();
    return Success<List<AppearanceOption>>(updated);
  }

  @override
  Future<Result<List<NotificationSetting>>> updateNotificationSetting(
    String id,
    bool value,
  ) async {
    final List<NotificationSetting> updated = _notificationSettings
        .map(
          (NotificationSetting setting) => setting.id == id
              ? setting.copyWith(value: value)
              : setting,
        )
        .toList();
    return Success<List<NotificationSetting>>(updated);
  }

  @override
  Future<Result<List<LanguageOption>>> updateLanguageOption(String id) async {
    final List<LanguageOption> updated = _languageOptions
        .map(
          (LanguageOption option) => option.copyWith(
            selected: option.id == id,
          ),
        )
        .toList();
    return Success<List<LanguageOption>>(updated);
  }
}
