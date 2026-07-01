# Quraaa Project Files

Generated file index for quick project navigation.

**Total tracked files:** ~320 files

**Status legend:**

- ✅ — Verified against `.ai` project rules.
- ⬜ — Not yet verified.

## Root Configuration

- `.env`
- `.flutter-plugins-dependencies`
- `.gitignore`
- `.metadata`
- `analysis_options.yaml`
- `devtools_options.yaml`
- `pubspec.lock`
- `pubspec.yaml`
- `README.md`

## Project Documentation

- ✅ `.ai/README.md`
- ✅ `.ai/project/architecture.md`
- ✅ `.ai/project/coding-standards.md`
- ✅ `.ai/project/workflow.md`
- `.ai/skills/code-review.md`
- `.ai/skills/create-tests.md`
- `.ai/skills/review.md`
- `.ai/skills/simplify.md`
- `.ai/skills/task-workflow.md`

## Source Code — `lib/`

### App Entry

- `lib/app/app.dart`
- `lib/main.dart`

### Config

- `lib/config/env/env.dart`
- `lib/config/routes/app_router.dart`
- `lib/config/routes/route_names.dart`
- `lib/config/routes/route_resolver.dart`

### Core

- `lib/core/core.dart`
- `lib/core/architecture/base_repository.dart`
- `lib/core/architecture/result.dart`
- `lib/core/architecture/syncable_entity.dart`
- `lib/core/architecture/use_case.dart`
- `lib/core/assets/app_assets.dart`
- ✅ `lib/core/assets/app_images.dart`
- `lib/core/connectivity/connection_status.dart`
- `lib/core/connectivity/connectivity_service.dart`
- `lib/core/connectivity/connectivity_service_impl.dart`
- `lib/core/connectivity/offline_route_guard.dart`
- `lib/core/constants/api_endpoints.dart`
- `lib/core/constants/app_storage_keys.dart`
- `lib/core/database/adapters/.gitkeep`
- `lib/core/database/database_service.dart`
- `lib/core/database/database_tables.dart`
- `lib/core/database/migrations/.gitkeep`
- `lib/core/database/storage_helper.dart`
- `lib/core/di/injection_container.dart`
- `lib/core/domain/entities/location.dart`
- `lib/core/error_monitoring/app_bloc_observer.dart`
- `lib/core/error_monitoring/app_logger.dart`
- `lib/core/error_monitoring/crashlytics_service.dart`
- `lib/core/error_monitoring/device_info_provider.dart`
- `lib/core/error_monitoring/dio_logging_interceptor.dart`
- `lib/core/error_monitoring/error_report.dart`
- `lib/core/error_monitoring/error_report_cache.dart`
- `lib/core/error_monitoring/navigation_tracker.dart`
- `lib/core/error_monitoring/telegram_notification_service.dart`
- `lib/core/error_monitoring/user_context_provider.dart`
- `lib/core/errors/error_codes.dart`
- `lib/core/errors/error_mapper.dart`
- `lib/core/errors/error_message_resolver.dart`
- `lib/core/errors/error_response_model.dart`
- `lib/core/errors/exceptions.dart`
- `lib/core/errors/failures.dart`
- `lib/core/localization/localization_constants.dart`
- `lib/core/localization/localization_service.dart`
- `lib/core/localization/supported_locales.dart`
- `lib/core/network/auth_interceptor.dart`
- `lib/core/network/endpoints.dart`
- `lib/core/network/http_helper.dart`
- `lib/core/services/app_diagnostics_service.dart`
- `lib/core/services/file_service.dart`
- `lib/core/services/firebase_notification_service.dart`
- `lib/core/services/logger_service.dart`
- `lib/core/services/notification_service.dart`
- `lib/core/services/storage_service.dart`
- `lib/core/services/storage_service_impl.dart`
- `lib/core/sync/conflict_resolver.dart`
- `lib/core/sync/pending_operation.dart`
- `lib/core/sync/sync_manager.dart`
- `lib/core/sync/sync_queue.dart`
- `lib/core/sync/sync_status.dart`
- `lib/core/sync/sync_worker.dart`
- `lib/core/utils/date_utils.dart`
- `lib/core/utils/debouncer.dart`
- `lib/core/utils/extensions.dart`
- ✅ `lib/core/utils/image_helper.dart`
- `lib/core/utils/validators.dart`

### Features

- `lib/features/features.dart`

#### Auth

- `lib/features/auth/auth.dart`
- `lib/features/auth/data/data.dart`
- `lib/features/auth/data/datasources/auth_local_datasource.dart`
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/auth/data/datasources/user_local_datasource.dart`
- `lib/features/auth/data/mappers/auth_mapper.dart`
- `lib/features/auth/data/mappers/user_mapper.dart`
- `lib/features/auth/data/models/user_model.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/domain/domain.dart`
- `lib/features/auth/domain/entities/user.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/domain/use_cases/login_use_case.dart`
- `lib/features/auth/domain/use_cases/register_use_case.dart`
- ✅ `lib/features/auth/presentation/bloc/auth_bloc.dart`
- ✅ `lib/features/auth/presentation/bloc/auth_event.dart`
- ✅ `lib/features/auth/presentation/bloc/auth_state.dart`
- ✅ `lib/features/auth/presentation/pages/landing_page.dart`
- `lib/features/auth/presentation/pages/location_permission_screen.dart`
- `lib/features/auth/presentation/pages/login_screen.dart`
- `lib/features/auth/presentation/pages/notification_permission_screen.dart`
- `lib/features/auth/presentation/pages/otp_verification_screen.dart`
- `lib/features/auth/presentation/pages/register_screen.dart`
- `lib/features/auth/presentation/presentation.dart`
- `lib/features/auth/presentation/widgets/auth_form_fields.dart`

#### Home

- `lib/features/home/home.dart`
- `lib/features/home/presentation/pages/audio_books_screen.dart`
- `lib/features/home/presentation/pages/cart_screen.dart`
- `lib/features/home/presentation/pages/home_screen.dart`
- `lib/features/home/presentation/pages/stores_screen.dart`
- `lib/features/home/presentation/pages/user_books_screen.dart`
- `lib/features/home/presentation/widgets/home_bottom_nav.dart`
- `lib/features/home/presentation/widgets/home_drawer.dart`
- `lib/features/home/presentation/widgets/home_feature_screen.dart`

#### Onboarding

- `lib/features/onboarding/onboarding.dart`
- `lib/features/onboarding/data/data.dart`
- `lib/features/onboarding/data/datasources/onboarding_local_datasource.dart`
- `lib/features/onboarding/data/datasources/onboarding_remote_datasource.dart`
- `lib/features/onboarding/data/models/category_model.dart`
- `lib/features/onboarding/data/repositories/onboarding_repository_impl.dart`
- `lib/features/onboarding/domain/domain.dart`
- `lib/features/onboarding/domain/entities/category.dart`
- `lib/features/onboarding/domain/entities/gender_selection.dart`
- `lib/features/onboarding/domain/entities/onboarding_draft.dart`
- `lib/features/onboarding/domain/repositories/onboarding_repository.dart`
- `lib/features/onboarding/domain/use_cases/complete_onboarding_use_case.dart`
- `lib/features/onboarding/domain/use_cases/load_categories_use_case.dart`
- `lib/features/onboarding/domain/use_cases/load_onboarding_state_use_case.dart`
- `lib/features/onboarding/domain/use_cases/save_birth_date_use_case.dart`
- `lib/features/onboarding/domain/use_cases/save_category_id_use_case.dart`
- `lib/features/onboarding/domain/use_cases/save_gender_use_case.dart`
- `lib/features/onboarding/presentation/bloc/onboarding_bloc.dart`
- `lib/features/onboarding/presentation/pages/age_onboarding_page.dart`
- `lib/features/onboarding/presentation/pages/gender_onboarding_page.dart`
- `lib/features/onboarding/presentation/pages/interests_onboarding_page.dart`
- `lib/features/onboarding/presentation/presentation.dart`

#### Profile

- `lib/features/account/data/user_data_local_data_source.dart`
- `lib/features/profile/data/datasources/profile_local_data_source.dart`
- `lib/features/profile/data/datasources/profile_remote_data_source.dart`
- `lib/features/profile/data/models/profile_model.dart`
- `lib/features/profile/data/repositories/profile_repository_impl.dart`
- `lib/features/profile/domain/repositories/profile_repository.dart`
- `lib/features/profile/presentation/bloc/profile_bloc.dart`
- `lib/features/profile/presentation/bloc/profile_event.dart`
- `lib/features/profile/presentation/bloc/profile_state.dart`
- `lib/features/profile/presentation/extensions/profile_model_ui_extensions.dart`
- `lib/features/profile/presentation/widgets/profile_info_shimmer.dart`

#### Search

- `lib/features/search/search.dart`
- `lib/features/search/presentation/pages/search_screen.dart`
- `lib/features/search/presentation/widgets/home_search_bar.dart`
- `lib/features/search/presentation/widgets/search_widget.dart`

#### Settings

- `lib/features/settings/.gitkeep`
- `lib/features/settings/data/.gitkeep`
- `lib/features/settings/domain/.gitkeep`
- `lib/features/settings/domain/entities/personal_information.dart`
- `lib/features/settings/presentation/pages/personal_information_screen.dart`
- `lib/features/settings/presentation/pages/settings_screen.dart`
- `lib/features/settings/presentation/pages/settings_search_screen.dart`
- `lib/features/settings/presentation/widgets/personal_data_card.dart`
- `lib/features/settings/presentation/widgets/personal_data_row.dart`
- `lib/features/settings/presentation/widgets/personal_data_section.dart`
- `lib/features/settings/presentation/widgets/personal_information_header.dart`
- `lib/features/settings/presentation/widgets/profile_avatar.dart`
- `lib/features/settings/presentation/widgets/profile_image_card.dart`

#### Splash

- `lib/features/splash/presentation/pages/splash_screen.dart`

#### Subscription

- `lib/features/subscription/presentation/pages/account_type_screen.dart`
- `lib/features/subscription/presentation/widgets/subscription_plan_card.dart`

### Legacy Screens

- `lib/screens/profile/bloc/edit_profile_bloc.dart`
- `lib/screens/profile/bloc/edit_profile_event.dart`
- `lib/screens/profile/bloc/edit_profile_state.dart`
- `lib/screens/profile/edit_profile_screen.dart`
- `lib/screens/profile/widgets/avatar_customization_tabs.dart`
- `lib/screens/profile/widgets/color_palette.dart`
- `lib/screens/profile/widgets/gender_dropdown.dart`
- `lib/screens/profile/widgets/phone_number_field.dart`
- `lib/screens/profile/widgets/profile_avatar_illustration.dart`
- `lib/screens/profile/widgets/profile_preview_card.dart`
- `lib/screens/profile/widgets/profile_text_field.dart`

### Shared

- `lib/shared/shared.dart`
- `lib/shared/constants/.gitkeep`
- `lib/shared/enums/.gitkeep`
- `lib/shared/extensions/.gitkeep`
- `lib/shared/extensions/app_context.dart`
- `lib/shared/models/.gitkeep`
- `lib/shared/models/message.dart`
- `lib/shared/theme/app_colors.dart`
- ✅ `lib/shared/theme/app_dimensions.dart`
- `lib/shared/theme/app_durations.dart`
- `lib/shared/theme/app_radius.dart`
- `lib/shared/theme/app_shadows.dart`
- `lib/shared/theme/app_spacing.dart`
- `lib/shared/theme/app_theme.dart`
- `lib/shared/theme/app_theme_cubit.dart`
- `lib/shared/theme/styles/app_bar.dart`
- ✅ `lib/shared/theme/styles/filled_button.dart`
- ✅ `lib/shared/theme/styles/outlined_button.dart`
- ✅ `lib/shared/theme/styles/text_button.dart`
- `lib/shared/theme/styles/text_input_feild.dart`
- `lib/shared/theme/styles/text_styles.dart`
- `lib/shared/widgets/animated_search_bar.dart`
- `lib/shared/widgets/app_shell.dart`
- `lib/shared/widgets/bottom_sheet_drag_handle.dart`
- `lib/shared/widgets/dev_debug_overlay.dart`
- `lib/shared/widgets/expandable_search_bar.dart`
- ✅ `lib/shared/widgets/app_image.dart`
- ✅ `lib/shared/widgets/app_layout.dart`
- `lib/shared/widgets/language_bottom_sheet.dart`
- `lib/shared/widgets/notification_bottom_sheet.dart`
- `lib/shared/widgets/onboarding_progress_indicator.dart`
- `lib/shared/widgets/onboarding_scaffold.dart`
- `lib/shared/widgets/phone_number_input.dart`
- `lib/shared/widgets/preference_selection_bottom_sheet.dart`
- `lib/shared/widgets/settings_action_button.dart`
- `lib/shared/widgets/settings_action_group.dart`
- `lib/shared/widgets/steps_indicator.dart`
- `lib/shared/widgets/terms_privacy_bottom_sheet.dart`
- `lib/shared/widgets/theme_bottom_sheet.dart`

### Test Helpers

- `lib/test_helpers/.gitkeep`

## Assets

- `assets/animations/.gitkeep`
- `assets/icons/.gitkeep`
- `assets/illustrations/boy.svg`
- `assets/illustrations/girl.svg`
- `assets/lottie/.gitkeep`
- `assets/mock_data/.gitkeep`
- `assets/images/onboarding.jpg`
- `assets/fonts/thmanyah_sans/thmanyahsans-Black.otf`
- `assets/fonts/thmanyah_sans/thmanyahsans-Bold.otf`
- `assets/fonts/thmanyah_sans/thmanyahsans-Light.otf`
- `assets/fonts/thmanyah_sans/thmanyahsans-Medium.otf`
- `assets/fonts/thmanyah_sans/thmanyahsans-Regular.otf`
- `assets/fonts/thmanyah_serif/thmanyahseriftext-Black.otf`
- `assets/fonts/thmanyah_serif/thmanyahseriftext-Bold.otf`
- `assets/fonts/thmanyah_serif/thmanyahseriftext-Light.otf`
- `assets/fonts/thmanyah_serif/thmanyahseriftext-Medium.otf`
- `assets/fonts/thmanyah_serif/thmanyahseriftext-Regular.otf`
- `assets/translations/ar.json`
- `assets/translations/en.json`

## Tests — `test/`

- `test/core/.gitkeep`
- `test/core/errors/error_mapper_test.dart`
- ✅ `test/core/utils/image_helper_test.dart`
- `test/core/utils/validators_test.dart`
- `test/features/auth/data/repositories/auth_repository_impl_test.dart`
- `test/features/auth/domain/use_cases/login_use_case_test.dart`
- ✅ `test/features/auth/presentation/bloc/auth_bloc_test.dart`
- `test/fixtures/.gitkeep`
- `test/helpers/.gitkeep`
- `test/mocks/.gitkeep`
- `test/mocks/mock_classes.dart`
- ✅ `test/shared/theme/styles/filled_button_test.dart`
- ✅ `test/shared/theme/styles/outlined_button_test.dart`
- ✅ `test/shared/theme/styles/text_button_test.dart`
- ✅ `test/shared/widgets/app_image_test.dart`
- `test/widget_test.dart`

## Android — `android/`

- `android/.gitignore`
- `android/app/build.gradle.kts`
- `android/app/src/debug/AndroidManifest.xml`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/java/com/example/quraaa/MainActivity.java`
- `android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java`
- `android/app/src/main/res/drawable-v21/launch_background.xml`
- `android/app/src/main/res/drawable/launch_background.xml`
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- `android/app/src/main/res/values-night/styles.xml`
- `android/app/src/main/res/values/styles.xml`
- `android/app/src/profile/AndroidManifest.xml`
- `android/build.gradle.kts`
- `android/gradle.properties`
- `android/gradle/wrapper/gradle-wrapper.jar`
- `android/gradle/wrapper/gradle-wrapper.properties`
- `android/gradlew`
- `android/gradlew.bat`
- `android/local.properties`
- `android/settings.gradle.kts`

## iOS — `ios/`

- `ios/.gitignore`
- `ios/Flutter/AppFrameworkInfo.plist`
- `ios/Flutter/Debug.xcconfig`
- `ios/Flutter/Generated.xcconfig`
- `ios/Flutter/Release.xcconfig`
- `ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift`
- `ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Sources/FlutterGeneratedPluginSwiftPackage/FlutterGeneratedPluginSwiftPackage.swift`
- `ios/Flutter/ephemeral/flutter_lldb_helper.py`
- `ios/Flutter/ephemeral/flutter_lldbinit`
- `ios/Flutter/ephemeral/flutter_native_integration.env`
- `ios/Flutter/flutter_export_environment.sh`
- `ios/Runner.xcodeproj/project.pbxproj`
- `ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata`
- `ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist`
- `ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings`
- `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`
- `ios/Runner.xcworkspace/contents.xcworkspacedata`
- `ios/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist`
- `ios/Runner.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings`
- `ios/Runner/AppDelegate.swift`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png`
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json`
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png`
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png`
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png`
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md`
- `ios/Runner/Base.lproj/LaunchScreen.storyboard`
- `ios/Runner/Base.lproj/Main.storyboard`
- `ios/Runner/GeneratedPluginRegistrant.h`
- `ios/Runner/GeneratedPluginRegistrant.m`
- `ios/Runner/Info.plist`
- `ios/Runner/Runner-Bridging-Header.h`
- `ios/Runner/SceneDelegate.swift`
- `ios/RunnerTests/RunnerTests.swift`

## macOS — `macos/`

- `macos/.gitignore`
- `macos/Flutter/Flutter-Debug.xcconfig`
- `macos/Flutter/Flutter-Release.xcconfig`
- `macos/Flutter/GeneratedPluginRegistrant.swift`
- `macos/Flutter/ephemeral/Flutter-Generated.xcconfig`
- `macos/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift`
- `macos/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Sources/FlutterGeneratedPluginSwiftPackage/FlutterGeneratedPluginSwiftPackage.swift`
- `macos/Flutter/ephemeral/flutter_export_environment.sh`
- `macos/Flutter/ephemeral/flutter_native_integration.env`
- `macos/Runner.xcodeproj/project.pbxproj`
- `macos/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist`
- `macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`
- `macos/Runner.xcworkspace/contents.xcworkspacedata`
- `macos/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist`
- `macos/Runner/AppDelegate.swift`
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png`
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png`
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png`
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png`
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png`
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png`
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png`
- `macos/Runner/Base.lproj/MainMenu.xib`
- `macos/Runner/Configs/AppInfo.xcconfig`
- `macos/Runner/Configs/Debug.xcconfig`
- `macos/Runner/Configs/Release.xcconfig`
- `macos/Runner/Configs/Warnings.xcconfig`
- `macos/Runner/DebugProfile.entitlements`
- `macos/Runner/Info.plist`
- `macos/Runner/MainFlutterWindow.swift`
- `macos/Runner/Release.entitlements`
- `macos/RunnerTests/RunnerTests.swift`

## Web — `web/`

- `web/favicon.png`
- `web/icons/Icon-192.png`
- `web/icons/Icon-512.png`
- `web/icons/Icon-maskable-192.png`
- `web/icons/Icon-maskable-512.png`
- `web/index.html`
- `web/manifest.json`

## Linux — `linux/`

- `linux/.gitignore`
- `linux/CMakeLists.txt`
- `linux/flutter/CMakeLists.txt`
- `linux/flutter/generated_plugin_registrant.cc`
- `linux/flutter/generated_plugin_registrant.h`
- `linux/flutter/generated_plugins.cmake`
- `linux/runner/CMakeLists.txt`
- `linux/runner/main.cc`
- `linux/runner/my_application.cc`
- `linux/runner/my_application.h`

## Windows — `windows/`

- `windows/.gitignore`
- `windows/CMakeLists.txt`
- `windows/flutter/CMakeLists.txt`
- `windows/flutter/generated_plugin_registrant.cc`
- `windows/flutter/generated_plugin_registrant.h`
- `windows/flutter/generated_plugins.cmake`
- `windows/runner/CMakeLists.txt`
- `windows/runner/Runner.rc`
- `windows/runner/flutter_window.cpp`
- `windows/runner/flutter_window.h`
- `windows/runner/main.cpp`
- `windows/runner/resource.h`
- `windows/runner/resources/app_icon.ico`
- `windows/runner/runner.exe.manifest`
- `windows/runner/utils.cpp`
- `windows/runner/utils.h`
- `windows/runner/win32_window.cpp`
- `windows/runner/win32_window.h`

## Logs

- `flutter_01.log`
- `flutter_02.log`
- `flutter_03.log`
- `flutter_04.log`
- `flutter_05.log`

---

Excluded from this index: `.git/`, `.dart_tool/`, `build/`, `.idea/`, `.junie/`, `.agents/`, Android Gradle build cache, and platform Pods.
