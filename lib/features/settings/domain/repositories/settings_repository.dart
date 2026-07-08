import '../../../../core/architecture/result.dart';
import '../entities/appearance_option.dart';
import '../entities/language_option.dart';
import '../entities/notification_setting.dart';
import '../entities/settings_section.dart';
import '../entities/settings_tab.dart';

/// Repository contract for the settings feature.
///
/// All implementations are currently dummy because the app does not support
/// these settings yet. The contract is kept so real storage can be plugged in
/// later without changing the presentation layer.
abstract class SettingsRepository {
  const SettingsRepository();

  /// Returns the five tabs shown in the settings screen.
  Future<Result<List<SettingsTab>>> getSettingsTabs();

  /// Returns the sections displayed under the Profile tab.
  Future<Result<List<SettingsSection>>> getProfileSections();

  /// Returns the sections displayed under the Settings tab.
  Future<Result<List<SettingsSection>>> getSettingsSections();

  /// Returns placeholder sections for the Library tab.
  Future<Result<List<SettingsSection>>> getLibrarySections();

  /// Returns placeholder sections for the Badges tab.
  Future<Result<List<SettingsSection>>> getBadgesSections();

  /// Returns placeholder sections for the Activity tab.
  Future<Result<List<SettingsSection>>> getActivitySections();

  /// Returns the available appearance options.
  Future<Result<List<AppearanceOption>>> getAppearanceOptions();

  /// Returns the available notification toggles.
  Future<Result<List<NotificationSetting>>> getNotificationSettings();

  /// Returns the available languages.
  Future<Result<List<LanguageOption>>> getLanguageOptions();

  /// Updates the selected appearance option.
  Future<Result<List<AppearanceOption>>> updateAppearanceOption(String id);

  /// Updates a single notification toggle.
  Future<Result<List<NotificationSetting>>> updateNotificationSetting(
    String id,
    bool value,
  );

  /// Updates the selected language.
  Future<Result<List<LanguageOption>>> updateLanguageOption(String id);
}
