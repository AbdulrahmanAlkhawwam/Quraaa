# Architecture decisions

Stack choices the clean-architecture audit and migration follow. Set 2026-09-22 by the project owner.

| Topic | Decision | Consequence for the audit |
|---|---|---|
| Either package | **fpdart** — `Either<Failure, T>` | The custom `core/architecture/result.dart` `Result<T>` will be replaced |
| HTTP client | **package:http behind `HttpHelper`** | Dio imports are flagged (C05) |
| Token storage | **Secure storage** for access and refresh tokens | Tokens in SharedPreferences are flagged (C06) |
| Environments | **`.env` + `--dart-define-from-file`**, no flavors | `.env` must never be tracked. Flavors are flagged as info |

Not decided yet (the audit notes them, but no rung changes them):
- Localization: the project uses `easy_localization` (C11, info). Moving to gen-l10n is out of scope unless decided here.
