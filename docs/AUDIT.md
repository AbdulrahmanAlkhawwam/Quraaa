# Architecture audit: Quraaa

Date: 2026-09-22   Branch: master   Commit: 8f07c34
Scanner score: **0/100**. Errors 136, warnings 131, info 223, for a raw penalty of **942 points**.

The score has a floor of 0, so it can't show progress on a project this far from the contract. **Penalty points are the number to track from here on.** After removing known scanner false positives (see below), the penalty is **889**.

Baseline before any change:
- `flutter analyze`: 140 issues. 1 error is in a test: `test/features/auth/presentation/bloc/auth_recovery_cubit_test.dart:182` declares `changePassword` twice. The rest are infos.
- `flutter test`: **325 passed, 5 failed.** Every rung must keep this same failing set (no larger):
  - `core/localization/localization_keys_test.dart` (setUpAll)
  - `features/auth/presentation/bloc/auth_recovery_cubit_test.dart` fails to load (the duplicate `changePassword` above)
  - `features/profile/presentation/cubit/profile_location_cubit_test.dart`: "changes the favorite location locally without updating the backend"
  - `shared/theme/styles/outlined_button_test.dart` ×2 (dark scheme, and foreground/background colors)

## In plain language: the three things that matter most

1. **A live Telegram bot token has been in git since June and is compiled into every build.** `.env` is listed in `.gitignore` but is still tracked, and 4 commits touch it. An earlier fix ("Codex/fix critical env secret #9", 96f1142) was **reverted** a week later (5d38167). Even with `.env` untracked, `TELEGRAM_BOT_TOKEN` goes into the APK through `--dart-define`. Anyone who unpacks the app can send messages as that bot. The only real fix is to **revoke the token in BotFather**, then move error forwarding behind the backend or rely on Crashlytics alone. `android/app/google-services.json` is also tracked and isn't ignored. → rung 7, plus manual actions only you can do.
2. **Access tokens, refresh tokens and the password are stored in plain SharedPreferences, in three places.** `AuthLocalDataSource` writes `access/refresh` keys, `UserLocalDataSource` writes a second set of `user_access_token/user_refresh_token` keys, and the cached profile JSON (`UserModel.toJson`) also includes `accessToken`, `refreshToken` and `password`. Three copies of one session can drift apart and cause "logged in but 401" bugs, and every copy can be read on a rooted device or from a backup. → rung 12, with a one-time migration so users stay logged in.
3. **The layer boundaries are only nominal.** The folders look like clean architecture, but auth's presentation imports `data/` 6 times, and profile's bloc imports two auth data sources. `AuthRepositoryImpl.login` only forwards the call. The actual login sequence (save user → set context → persist tokens → mark session) lives in `AuthSessionService` (in `data/services`), and `AuthBloc` calls it directly. The `User` entity carries `password` and the tokens, so domain objects double as persistence models. The data-access model is `Map` → mapper → entity, and models don't extend entities (22 × C17). Error results are a home-made `Result<T>` whose failure branch is a `String` plus an untyped `cause`, so blocs have to downcast (`failure.cause is OtpVerificationRequiredFailure`). → rung 11.

## Decisions this audit assumed
- Either package: fpdart
- HTTP: package:http + HttpHelper (Dio is flagged)
- Tokens: secure storage (access and refresh)
- Environments: `.env` + `--dart-define-from-file`
(Source: answered at step 2, now recorded in [DECISIONS.md](DECISIONS.md).)

## Findings by rule

| Rule | Count | Gloss |
|---|---|---|
| C11 | 100 | easy_localization in use (info, out of scope) |
| N03 | 80 | class ≠ file name (info) |
| S04 | 61 | folder aliases: `datasources`×14, `pages`×18, `widgets`×13, `bloc`×10, `cubit`×6 |
| S05 | 40 | no per-feature `_injection`/`_routes` |
| S03 | 37 | missing layers or sub-folders (search, splash, subscription have only presentation; account has no presentation) |
| C05 | 25 | Dio imports |
| C18 | 24 | entities without copyWith (info) |
| C17 | 22 | models don't extend entities |
| C10 | 15 | secret-looking literals (see false positives) |
| D06 | 14 | "repository not abstract", **all false positives** |
| D03 | 10 | presentation → data imports (auth ×6, profile ×3, pdf_reader ×1) |
| C15 | 10 | screens with ≥3 setState (info) |
| C02 | 10 | hardcoded asset paths |
| C06 | 9 | tokens written to plain prefs |
| C01 | 6 | hardcoded URLs (Telegram API, book_assistant ×3, OSM tiles, env default) |
| D05 | 5 | repo impl without try (account, books, onboarding, profile, settings) |
| C03 | 5 | `Image.network` |
| C19 | 5 | features with no tests: favorites, local_explorer, search, splash, subscription |
| C09 | 4 | `.env` + `google-services.json` tracked; google-services/GoogleService-Info not ignored |
| S07 | 3 | `lib/app`, `lib/config`, `lib/shared` outside core/features |
| C13 | 3 | no `app_routes.dart` / `service_locator.dart` / `routing/app_router.dart` (they exist as `config/routes/route_names.dart`, `di/injection_container.dart`, `config/routes/app_router.dart`) |
| D07 | 1 | libraries → home presentation |
| C14 | 1 | no fpdart in pubspec |

Full table: [audit-findings.md](audit-findings.md).

### Scanner false positives (verified by hand)
- **D06 ×14:** every domain repository *is* `abstract class`. The scanner's regex lets `^\s*` cross a newline, so it checks the wrong 40-character window.
- **C10 ×5** in `route_names.dart` / `api_endpoints.dart`: route paths like `'/forgot-password'` match the "password = '…'" pattern.
- **C10 ×10** in `firebase_options.dart`: Firebase client API keys are designed to ship in the app. Keep them, but restrict them in Google Cloud Console (by Android package/SHA and iOS bundle ID).

## Manual findings (reference feature: auth, and core top-down)

- **Repository sequencing:** ✗. `AuthRepositoryImpl` only forwards. The login/refresh sequencing lives in `data/services/auth_session_service.dart` and is called by `AuthBloc`, `AuthRecoveryCubit` and `AuthInterceptor`. Under the contract it moves into the repository, and the service disappears.
- **Exception → failure:** ✓ mostly. There's one `ErrorMapper` (376 lines) and a typed `Failure` hierarchy (385 lines). The typed failure is then flattened into `ResultFailure(message, cause: failure)`, so the type is lost at the domain boundary.
- **Model vs entity:** ✗. `User` (the entity) holds `password`, `accessToken`, `refreshToken` and device fields. Remote data sources return raw `Map`s, and mappers build entities. `UserModel extends User`, but most other models don't.
- **Use cases:** ✓ for auth (8 use cases, all used). Several blocs still read data sources directly (`AuthLocalDataSource` injected into `AuthBloc` as `_authJourney`).
- **Cubit vs bloc:** acceptable. `AuthRecoveryCubit` (290 lines, several async domain calls) is a bloc in all but name.
- **Screens holding logic:** 59 `Navigator.push/of` calls sit alongside GoRouter. `register_screen.dart` is 644 lines.
- **God files (>400 lines):** 25 files. Worst: `core/di/injection_container.dart` (1120 lines, 168 registrations), `shared/widgets/app_shell.dart` (1110), `libraries/.../book_details_screen.dart` (944), `pdf_page_image.dart` (909), `purchases/data/secure_purchase_book_data_source.dart` (852, and it sits outside `data_sources/`).
- **Session handling:** ✓ good. `AuthInterceptor` already has single-flight refresh (`_refreshInFlight`), a no-retry-on-retry guard against 401 loops, and a clean expire path. Keep this logic when the client changes.
- **Routing:** ✓. GoRouter with an async `redirect` guard already exists (47 routes), but it's all in one `app_router.dart` (562 lines).
- **Localization:** `easy_localization` with a 912-line constants file. There are 39 hardcoded `Text('…')` strings.
- **Responsive:** fine, with only 1 scattered breakpoint check.
- **Tests:** 90 test files, 15 of 20 features covered. **There's a real safety net, so no pre-rung-11 test backfill is needed for auth.**

## Migration plan

| Rung | Scope | Rules | Effort | Behaviour change | Include? |
|---|---|---|---|---|---|
| 7  | hygiene: untrack `.env` + `google-services.json`, fix `.gitignore`, fix the broken test, commit the scanner as `tool/` | C09 | S | none (you revoke the Telegram token by hand) | ☐ |
| 8  | renames: 61 folder aliases, suffixes, `lib/app|config|shared` → `lib/core` | S04 N02 S06 S07 | M–L (rewrites imports in ~500 files) | none | ☐ |
| 9  | core skeleton: fpdart, `AppRoutes`, `service_locator`, `routing/app_router`, `StorageKeys`, base `UseCase` on Either | C13 C14 | S | none | ☐ |
| 10 | constants: URLs → `ApiEndpoints`/`AppConfig`, assets → `AppAssets` | C01 C02 | S | none | ☐ |
| 11 | dependencies: `Result` → `Either<Failure,T>` (118 files), strip data imports from presentation, move session sequencing into repositories, remove password/tokens from `User`, models extend entities, add try to 5 repos | D03 D05 D07 C17 C18 | **L–XL**, one commit per feature, auth first | possible, test after each feature | ☐ |
| 12 | storage & network: tokens → `flutter_secure_storage` with a one-time prefs→secure migration, one token store instead of three, Dio → http + HttpHelper, `Image.network` → image helper | C03 C05 C06 | **L** (storage) + **XL** (Dio: 25 files and 4 Dio interceptors to re-implement) | session migration, re-test login by hand | ☐ |
| 13 | DI & routing: split the 1120-line container into 20 `<feature>_injection.dart` files and the router into `<feature>_routes.dart` | S05 | M–L (already GoRouter, so no rewrite) | none intended | ☐ |
| 14 | presentation: setState screens → cubits, split god screens, state views, remaining `Navigator.push` → GoRouter | C15 | L | none intended | ☐ |
| 15 | tests + verify: tests for favorites/local_explorer/search/splash/subscription, full auth coverage, re-scan, before/after here | C19 | M | none | ☐ |

Effort: S < 1h · M half day · L 1–2 days · XL more.

Out of scope unless decided: easy_localization → gen-l10n (C11, 100 files), the N03 naming infos, and moving search/splash/subscription to full three-layer features (S03: they are UI-only, and empty `data/`/`domain/` folders add nothing).

## Risks
- **Open branches:** all five remote branches are already in master. `add-notification` was merged normally. The other four were squash-merged: `codex/fix-routing-7-29` → #11, `refactor-onboarding` → #12, `add-books-screen` → #13, `fix-pdf-reader` → #15. For each of them, `lib/` and `test/` at the branch tip are identical to the tree of its squash commit. `git cherry` reports them as unmerged only because squashing rewrites the commits. Merging them again would raise ~190 conflicts over code master has since replaced. They can be deleted, and rung 8 has no branch-conflict risk.
- **Dio → http (rung 12)** re-implements a working auth/refresh/connectivity/language interceptor stack. It's the riskiest change for the least user-visible benefit.
- **Secure storage:** without the migration step, every existing user is logged out on update.
- **Git history:** removing `.env` from tracking doesn't remove it from history. Rewriting history (filter-repo) needs a force-push and every clone to re-clone. Revoking the token is the part that actually protects you.

## After migration
Score before: 0/100 (penalty 942) → after: _pending_
Commits: _pending_
Deferred: _pending_
