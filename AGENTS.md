# Quraaa — Agent Guide

This file is written for AI coding agents who need to work on the Quraaa Flutter application. It summarizes the project structure, conventions, build/test workflow, and the current state of the codebase based on the actual files in the repository.

---

## Project Overview

**Quraaa** is a cross-platform Flutter application intended to become an Arabic smart-reading ecosystem (ebooks, physical books, audiobooks, community, AI assistant, author tools, etc.). At the time of writing, the project is in an early scaffolding phase: the architecture, design system, localization, and test skeleton are in place, but most features and infrastructure implementations are stubs.

The repository contains only the **Flutter frontend**. The backend (described in `docs/README.md` as NestJS + PostgreSQL) is not part of this repository.

Key facts:

- Package name: `quraaa`
- Flutter project version: `1.0.0+1`
- Dart SDK: `^3.12.0`
- Default Android application ID: `com.example.quraaa` (update before release)
- Proprietary project — do not publish to pub.dev (`publish_to: 'none'`)

---

## Technology Stack

| Concern | Package / Tool | Notes |
|---|---|---|
| Framework | Flutter + Dart | Cross-platform UI (`lib/main.dart` entry point) |
| State management | `flutter_bloc` | BLoC/Cubit pattern |
| Dependency injection | `get_it` | Global service locator exposed as `sl` in `lib/core/di/injection_container.dart` |
| Navigation | `go_router` | Declarative routing in `lib/config/routes/app_router.dart` |
| Networking | `dio` | Listed as a dependency, but no concrete API client exists yet |
| Localization | `easy_localization` | English (`en`) and Arabic (`ar`), RTL-aware |
| Value equality | `equatable` | Used for `Failure` and model classes |
| UI icons | `cupertino_icons` | iOS-style icon font |
| Testing | `flutter_test`, `mocktail` | Mocktail used for repository/data-source mocks |
| Linting | `flutter_lints` | Configured via `analysis_options.yaml` |

Packages that the documentation mentions (Drift, `flutter_secure_storage`, `envied`, `connectivity_plus`, etc.) are **not currently declared in `pubspec.yaml`** and are not wired up in code. Only the abstract contracts for storage, database, connectivity, and sync exist.

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app/
│   └── app.dart                       # QuraaaApp widget (MaterialApp.router)
├── config/
│   ├── env/env.dart                   # Hard-coded environment constants
│   └── routes/                        # GoRouter configuration and route names
├── core/
│   ├── architecture/                  # Result, UseCase, BaseRepository, SyncableEntity
│   ├── assets/                        # Typed asset-path constants (icons, images, animations, etc.)
│   ├── connectivity/                  # Connectivity service/bloc contracts
│   ├── database/                      # Database service/table contracts
│   ├── di/                            # GetIt service-locator setup
│   ├── errors/                        # Exceptions, Failures, ErrorMapper, error codes
│   ├── localization/                  # Easy Localization setup and helpers
│   ├── services/                      # Storage, logger, notification, file contracts
│   ├── sync/                          # Sync manager/queue/worker/conflict contracts
│   └── utils/                         # Date, debounce, extensions, validators
├── features/
│   └── auth/                          # Only feature implemented as a skeleton
│       ├── data/                      # Models, mappers, data sources, repository impl
│       ├── domain/                    # Entities, repository interface, use cases
│       └── presentation/              # BLoC, pages, view models
└── shared/
    ├── theme/                         # Design tokens and AppTheme
    └── widgets/                       # Shared widgets (currently AppShell only)
```

### Import rules

- **Feature isolation**: A feature must not import another feature's internal `data/`, `domain/`, or `presentation/` files directly. Use public barrel files (`features/<name>/<name>.dart`) or shared code in `core/`.
- **Domain purity**: `features/<name>/domain/` should depend only on Dart standard library (no Flutter, Dio, Drift, GetIt, etc.).
- **Data purity**: `features/<name>/data/` may import `domain/` and `core/` but not `presentation/`.
- **Presentation**: Outer layer; may import anything.

---

## Architecture Patterns

### Clean Architecture + Feature-First

Each feature is self-contained and split into three layers:

1. **Domain** — entities, repository interfaces, use cases (`features/<name>/domain/`).
2. **Data** — models, mappers, data sources, repository implementations (`features/<name>/data/`).
3. **Presentation** — BLoC/Cubit, pages, widgets, view models (`features/<name>/presentation/`).

### Core abstractions

- `UseCase<Type, Params>` in `lib/core/architecture/use_case.dart`: every use case implements `Future<Type> call(Params params)`.
- `Result<T>` in `lib/core/architecture/result.dart`: sum type with `Success<T>` and `ResultFailure<T>`.
- `BaseRepository<T>` in `lib/core/architecture/base_repository.dart`: enforces `getCached()` and `sync()` for offline-first repositories.
- `SyncableEntity` in `lib/core/architecture/syncable_entity.dart`: contract for entities that can be synced (`id`, `updatedAt`, `isDirty`).

### Error handling

The project uses a typed error pipeline:

- `AppException` hierarchy (data/remote layer throwables).
- `Failure` hierarchy (domain/UI-facing errors, extends `Equatable`).
- `ErrorMapper` centralizes conversion between `ErrorResponseModel`, `AppException`, and `Failure`.

Important implementation note: `ErrorMapper.mapExceptionToFailure` currently uses `case TypeName:` instead of `case instance:` in several branches, which means most exceptions fall through to `UnknownFailure`. This is a known bug in the scaffolding code.

### Offline-first / sync

The architecture intends to use local storage as the source of truth and queue remote writes for background synchronization. Contracts exist for `SyncManager`, `SyncQueue`, `SyncWorker`, `PendingOperation`, and `ConflictResolver`, but no concrete implementation is wired yet.

---

## Current State of the Codebase

Be aware that much of the code is scaffolding rather than working implementation:

- `lib/core/di/injection_container.dart`: `registerCoreDependencies()`, `registerFeatureDependencies()`, and `registerTestDependencies()` are all empty. No services are registered in GetIt.
- `lib/features/auth/`: the only feature. `AuthRepositoryImpl`, `AuthLocalDataSource`, and `AuthRemoteDataSource` are abstract/stubbed (`UnimplementedError`). `AuthBloc` emits hard-coded success. `LoginPage` and `AppShell` are placeholder widgets.
- Core services (`StorageService`, `DatabaseService`, `ConnectivityService`, `LoggerService`, etc.) are abstract contracts only.
- No concrete Dio API client, interceptors, or remote endpoints exist.
- No CI/CD configuration (no `.github/workflows/`, no fastlane, etc.).
- `.env` exists but `lib/config/env/env.dart` is a simple hard-coded class, not using `envied`.
- Core library desugaring is enabled in `android/app/build.gradle.kts` to satisfy `flutter_local_notifications` requirements.

When adding new functionality, you will usually need to:

1. Add the concrete implementation to `core/` or the feature's `data/` layer.
2. Register it in `lib/core/di/injection_container.dart`.
3. Update or add barrel files (`core/core.dart`, `features/<name>/<name>.dart`, etc.).
4. Add/update tests under `test/`.

---

## Build and Run Commands

Install dependencies:

```bash
flutter pub get
```

Run static analysis:

```bash
flutter analyze
```

Run the app on a connected device or emulator:

```bash
flutter run
```

Build a release APK (Android):

```bash
flutter build apk --release
```

Build for iOS (macOS only):

```bash
flutter build ios --release
```

The project uses the standard Flutter toolchain. No custom code-generation step is required at this stage (the documentation mentions `build_runner` for Drift/envied, but those packages are not currently used).

---

## Testing Instructions

Run all tests:

```bash
flutter test
```

Run a specific test file:

```bash
flutter test test/core/errors/error_mapper_test.dart
```

### Test structure

- `test/helpers/test_di.dart` — test dependency-injection helper (`configureTestDependencies` is currently empty).
- `test/mocks/mock_classes.dart` — Mocktail mocks for repository/data-source/use-case boundaries.
- `test/core/errors/error_mapper_test.dart` — only fully implemented test at this time.
- `test/features/auth/...` — placeholder test skeletons for repository, use case, and BLoC.

### Testing conventions

- Use `mocktail` for mocking (`class MockX extends Mock implements X {}`).
- Use `flutter_test` for unit and widget tests.
- Follow the existing feature folder mirror under `test/features/<name>/...`.
- Test dependency registration should eventually be added to `registerTestDependencies()` in `lib/core/di/injection_container.dart`.

---

## Code Style Guidelines

- **Linter**: `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`. Prefer enabling stricter rules only after the scaffold stabilizes.
- **Formatting**: `dart format` (standard Flutter style). Prefer trailing commas for multi-line parameter/argument lists.
- **Naming**:
  - Files: `snake_case.dart`.
  - Classes: `PascalCase`.
  - Private members: `_leadingUnderscore`.
  - Use cases: `<Verb><Noun>UseCase` (e.g., `LoginUseCase`).
  - Repository interface: `<Feature>Repository`; implementation: `<Feature>RepositoryImpl`.
- **Barrel files**: each layer and each feature exports its public API through a `*.dart` file with the same name as its directory (e.g., `features/auth/data/data.dart`).
- **Imports**: prefer importing from barrel files rather than deep internal paths; respect the layer dependency rules.
- **Strings**: all user-facing strings live in `assets/translations/en.json` and `assets/translations/ar.json` and are accessed via `easy_localization` helpers (see `lib/core/localization/`).
- **Comments and documentation**: English is the language used in code comments and markdown documentation. Keep comments concise and up to date.

---

## Localization

- Supported locales: **English (`en`)** and **Arabic (`ar`)**.
- Fallback locale: English.
- `LocalizationService.wrap()` configures `EasyLocalization` with `useOnlyLangCode: true` and `saveLocale: false`.
- Add new translation keys to both `assets/translations/en.json` and `assets/translations/ar.json`, keeping the nested namespace structure.
- The app supports RTL; test Arabic layouts when adding UI.

---

## Security Considerations

- `.env` is present in the repository but **should not contain production secrets** in version control. The project currently does not use `envied` or encrypted storage, so secrets would be plain text.
- No secure-storage implementation exists yet. Tokens, credentials, and sensitive user data must eventually be stored via a secure mechanism (e.g., `flutter_secure_storage`), not `SharedPreferences` or plain JSON.
- The Android release build currently signs with the debug keystore (`signingConfig = signingConfigs.getByName("debug")`). Replace this with a production signing configuration before any store release.
- The application ID is still `com.example.quraaa`. Change it to the production package name before release.
- Do not hard-code API keys or backend URLs in source files; use environment configuration.

---

## Useful References

- Entry point: `lib/main.dart`
- App widget: `lib/app/app.dart`
- Routes: `lib/config/routes/app_router.dart`
- DI container: `lib/core/di/injection_container.dart`
- Error handling: `lib/core/errors/error_mapper.dart`, `lib/core/errors/failures.dart`
- Localization: `lib/core/localization/localization_service.dart`
- Design tokens: `lib/shared/theme/`
- Feature example: `lib/features/auth/`
- Tests: `test/`
- Human-readable project docs: `docs/README.md`, `docs/architecture/architecture.md`
