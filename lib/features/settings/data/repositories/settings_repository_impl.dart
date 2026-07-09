import '../../../../core/architecture/result.dart';
import '../../../../core/constants/app_storage_keys.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/appearance_option.dart';
import '../../domain/entities/language_option.dart';
import '../../domain/entities/notification_setting.dart';
import '../../domain/entities/settings_section.dart';
import '../../domain/entities/settings_tab.dart';
import '../../domain/repositories/settings_repository.dart';

/// Local settings repository backed by [StorageService].
class SettingsRepositoryImpl extends SettingsRepository {
  SettingsRepositoryImpl(this._storageService);

  final StorageService _storageService;

  static const Set<String> _supportedAppearanceIds = <String>{
    'light',
    'dark',
    'system',
  };

  static const Set<String> _supportedLanguageIds = <String>{
    'en',
    'ar',
  };

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

  static const List<AppearanceOption> _appearanceOptions = <AppearanceOption>[
    AppearanceOption(
      id: 'light',
      labelKey: 'settings.appearance.lightMode',
      mode: AppearanceMode.light,
      selected: false,
    ),
    AppearanceOption(
      id: 'dark',
      labelKey: 'settings.appearance.darkMode',
      mode: AppearanceMode.dark,
      selected: false,
    ),
    AppearanceOption(
      id: 'system',
      labelKey: 'settings.appearance.deviceSystem',
      mode: AppearanceMode.system,
      selected: false,
    ),
  ];

  static const List<NotificationSetting> _notificationSettings =
      <NotificationSetting>[
    NotificationSetting(
      id: 'new_update',
      labelKey: 'settings.notification.newUpdate',
      value: true,
    ),
    NotificationSetting(
      id: 'ads',
      labelKey: 'settings.notification.ads',
      value: false,
    ),
    NotificationSetting(
      id: 'payment',
      labelKey: 'settings.notification.payment',
      value: true,
    ),
    NotificationSetting(
      id: 'new_book_version',
      labelKey: 'settings.notification.newBookVersion',
      value: true,
    ),
    NotificationSetting(
      id: 'finish_book',
      labelKey: 'settings.notification.finishBook',
      value: true,
    ),
    NotificationSetting(
      id: 'get_new_badge',
      labelKey: 'settings.notification.getNewBadge',
      value: false,
    ),
    NotificationSetting(
      id: 'upgrade_level',
      labelKey: 'settings.notification.upgradeLevel',
      value: true,
    ),
  ];

  static const List<LanguageOption> _languageOptions = <LanguageOption>[
    LanguageOption(
      id: 'en',
      labelKey: 'settings.language.english',
      languageCode: 'en',
      selected: false,
    ),
    LanguageOption(
      id: 'ar',
      labelKey: 'settings.language.arabic',
      languageCode: 'ar',
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
      List<AppearanceOption>.unmodifiable(
        _selectedAppearanceOptions(
          _storageService.getString(AppStorageKeys.appThemeMode),
        ),
      ),
    );
  }

  @override
  Future<Result<List<NotificationSetting>>> getNotificationSettings() async {
    return Success<List<NotificationSetting>>(
      List<NotificationSetting>.unmodifiable(_selectedNotificationSettings()),
    );
  }

  @override
  Future<Result<List<LanguageOption>>> getLanguageOptions() async {
    return Success<List<LanguageOption>>(
      List<LanguageOption>.unmodifiable(
        _selectedLanguageOptions(
          _storageService.getString(AppStorageKeys.userLanguage),
        ),
      ),
    );
  }

  @override
  Future<Result<List<AppearanceOption>>> updateAppearanceOption(String id) async {
    final String selectedId = _normalizeAppearanceId(id);
    await _storageService.setString(AppStorageKeys.appThemeMode, selectedId);
    return Success<List<AppearanceOption>>(
      List<AppearanceOption>.unmodifiable(_selectedAppearanceOptions(selectedId)),
    );
  }

  @override
  Future<Result<List<NotificationSetting>>> updateNotificationSetting(
    String id,
    bool value,
  ) async {
    await _storageService.setBool(_notificationStorageKey(id), value);
    return getNotificationSettings();
  }

  @override
  Future<Result<List<LanguageOption>>> updateLanguageOption(String id) async {
    final String selectedId = _normalizeLanguageId(id);
    await _storageService.setString(AppStorageKeys.userLanguage, selectedId);
    return Success<List<LanguageOption>>(
      List<LanguageOption>.unmodifiable(_selectedLanguageOptions(selectedId)),
    );
  }

  List<AppearanceOption> _selectedAppearanceOptions(String? selectedId) {
    final String normalizedId = _normalizeAppearanceId(selectedId);
    return _appearanceOptions
        .map(
          (AppearanceOption option) => option.copyWith(
            selected: option.id == normalizedId,
          ),
        )
        .toList(growable: false);
  }

  List<NotificationSetting> _selectedNotificationSettings() {
    return _notificationSettings
        .map(
          (NotificationSetting setting) => setting.copyWith(
            value: _storageService.getBool(_notificationStorageKey(setting.id)) ??
                setting.value,
          ),
        )
        .toList(growable: false);
  }

  List<LanguageOption> _selectedLanguageOptions(String? selectedId) {
    final String normalizedId = _normalizeLanguageId(selectedId);
    return _languageOptions
        .map(
          (LanguageOption option) => option.copyWith(
            selected: option.id == normalizedId,
          ),
        )
        .toList(growable: false);
  }

  static String _normalizeAppearanceId(String? id) {
    return _supportedAppearanceIds.contains(id) ? id! : 'system';
  }

  static String _normalizeLanguageId(String? id) {
    return _supportedLanguageIds.contains(id) ? id! : 'en';
  }

  static String _notificationStorageKey(String id) {
    return 'settings.notification.$id';
  }
}
