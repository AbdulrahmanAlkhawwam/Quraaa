# Firebase App Distribution (Android)

This document describes how to build and distribute Android releases of Quraaa through Firebase App Distribution.

The integration uses the **Firebase CLI** (`firebase appdistribution:distribute`) rather than the Gradle plugin. This keeps the existing Android Gradle configuration untouched and makes the same workflow usable locally and in CI/CD.

---

## Table of contents

- [Prerequisites](#prerequisites)
- [Firebase CLI installation](#firebase-cli-installation)
- [Login command](#login-command)
- [Configuration](#configuration)
  - [How to obtain the Android App ID](#how-to-obtain-the-android-app-id)
  - [How to create tester groups](#how-to-create-tester-groups)
  - [Local `.env` file](#local-env-file)
- [Release scripts](#release-scripts)
  - [PowerShell](#powershell)
  - [Bash](#bash)
- [GitHub Actions](#github-actions)
  - [Required secrets](#required-secrets)
  - [Manually triggering a release](#manually-triggering-a-release)
- [Common errors and solutions](#common-errors-and-solutions)

---

## Prerequisites

1. A working Flutter development environment matching the project's SDK constraint (`^3.12.0`).
2. The Android toolchain configured and able to build release APKs/AABs.
3. Access to the Firebase project `quraa-otp` with permissions to manage App Distribution.
4. The Firebase CLI installed (see below).
5. Existing Firebase configuration files must remain unchanged:
   - `android/app/google-services.json`
   - `lib/firebase_options.dart`
   - `firebase.json`

> **Important:** The existing Firebase Authentication setup is **not** modified by this integration.

---

## Firebase CLI installation

### macOS / Linux

```bash
curl -sL https://firebase.tools | bash
```

### Windows

```powershell
npm install -g firebase-tools
```

Or download the standalone binary from the [Firebase CLI releases page](https://github.com/firebase/firebase-tools/releases).

Verify the installation:

```bash
firebase --version
```

---

## Login command

For local development, authenticate the Firebase CLI with your Google account:

```bash
firebase login
```

This opens a browser window and stores a refresh token locally. The token is **not** committed to the repository.

For CI/CD, use a service account instead (see [GitHub Actions](#github-actions)).

---

## Configuration

### How to obtain the Android App ID

1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Select the **quraa-otp** project.
3. Go to **Project settings** (gear icon) → **General**.
4. Under **Your apps**, select the Android app.
5. Copy the **App ID** (e.g. `1:126486177996:android:6e7a7fe20bcb49fc3bfa69`).

Alternatively, you can read it from the committed configuration files:

- `firebase.json` → `flutter.platforms.android.default.appId`
- `android/app/google-services.json` → `client.mobilesdk_app_id`

### How to create tester groups

1. In the Firebase Console, go to **App Distribution** → **Testers & Groups**.
2. Click **Add group**.
3. Enter a group name (e.g. `beta-testers`, `qa-team`).
4. Add testers by email.

Groups are referenced by their **name** (not display title). Multiple groups can be passed as a comma-separated list, e.g. `beta-testers,qa-team`.

### Local `.env` file

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

Example `.env` entries for App Distribution:

```dotenv
FIREBASE_ANDROID_APP_ID=1:126486177996:android:6e7a7fe20bcb49fc3bfa69
FIREBASE_TESTER_GROUPS=beta-testers
```

> `.env` is already listed in `.gitignore` and must never be committed or added
> to `pubspec.yaml`. The release scripts read it in the terminal and forward
> only `HOST`, `BASEURL`, `APP_ENV`, and `LATEST_VERSION` through
> `--dart-define`; unrelated credentials are not compiled into the app.

Optional variables:

| Variable | Purpose |
|----------|---------|
| `FIREBASE_PROJECT_ID` | Used when no default Firebase project is selected in the CLI. |
| `GOOGLE_APPLICATION_CREDENTIALS` | Absolute path to a service account JSON key for non-interactive uploads. |
| `FIREBASE_TOKEN` | Legacy Firebase CLI token. Prefer `firebase login` locally and a service account in CI. |

---

## Release scripts

Two release scripts are provided in `scripts/`:

- `scripts/release_android.ps1` — for Windows / PowerShell
- `scripts/release_android.sh` — for macOS / Linux / Git Bash

Both scripts:

1. Load environment variables from `.env`.
2. Validate the Firebase settings and the required `HOST`/`BASEURL` values.
3. Pass the whitelisted runtime values to Flutter using terminal
   `--dart-define` arguments.
4. Build the requested release artifact (`apk` or `aab`).
5. Upload the artifact to Firebase App Distribution with release notes and tester groups.

### PowerShell

```powershell
# Build APK and distribute to the default tester group
.\scripts\release_android.ps1

# Build AAB
.\scripts\release_android.ps1 -BuildType aab

# Build APK with custom release notes and tester group
.\scripts\release_android.ps1 -BuildType apk -ReleaseNotes "Bug fixes" -Groups "qa-team"
```

### Bash

```bash
# Build APK and distribute to the default tester group
./scripts/release_android.sh

# Build AAB
./scripts/release_android.sh aab

# Build APK with custom release notes and tester group
./scripts/release_android.sh apk "Bug fixes"
```

---

## GitHub Actions

A manually-triggered workflow is provided in `.github/workflows/firebase_app_distribution.yml`.

### Required secrets

Create the following secrets in the GitHub repository (**Settings → Secrets and variables → Actions → Repository secrets**):

| Secret | Value |
|--------|-------|
| `FIREBASE_SERVICE_ACCOUNT` | The full JSON content of a Firebase service account key. |
| `FIREBASE_ANDROID_APP_ID` | The Android App ID from Firebase Console. |
| `FIREBASE_TESTER_GROUPS` | Comma-separated list of tester group names. |
| `FIREBASE_PROJECT_ID` *(optional)* | Firebase project ID, e.g. `quraa-otp`. |

### Required repository variables

Create these under **Settings → Secrets and variables → Actions →
Variables**. They are passed to Flutter as compile-time values and are not
secrets.

| Variable | Value |
|----------|-------|
| `HOST` | Backend host, for example `api.quraa.dev`. |
| `BASEURL` | Backend API path, for example `api`. |
| `LATEST_VERSION` *(optional)* | Latest published application version. |

#### Creating the service account key

1. In the Firebase Console, open **Project settings** → **Service accounts**.
2. Click **Generate new private key**.
3. Save the downloaded JSON file securely.
4. Copy the entire file contents into the `FIREBASE_SERVICE_ACCOUNT` GitHub secret.

> Never commit the service account JSON file. It is already ignored via `.gitignore` (`*-service-account.json`).

### Manually triggering a release

1. Go to **Actions** in the GitHub repository.
2. Select **Firebase App Distribution (Android)**.
3. Click **Run workflow**.
4. Choose the build type (`apk` or `aab`) and optionally enter release notes.
5. Click **Run workflow**.

---

## Common errors and solutions

### `firebase command not found`

The Firebase CLI is not installed or not on `PATH`. Install it and run `firebase --version` to verify.

### `FIREBASE_ANDROID_APP_ID is not set`

Add the Android App ID to `.env` (local) or to the `FIREBASE_ANDROID_APP_ID` GitHub secret (CI).

### `FIREBASE_TESTER_GROUPS is not set`

Add the tester group names to `.env` (local) or to the `FIREBASE_TESTER_GROUPS` GitHub secret (CI).

### `Error: Failed to authenticate, have you run firebase login?`

- **Local:** Run `firebase login`.
- **CI:** Ensure `FIREBASE_SERVICE_ACCOUNT` is set and valid. The workflow writes the secret to a temporary file and points `GOOGLE_APPLICATION_CREDENTIALS` at it.

### `Error: Could not find the Firebase app`

The App ID does not match an Android app registered in the Firebase project. Double-check `FIREBASE_ANDROID_APP_ID` against Firebase Console.

### `Flutter build failed`

- Ensure `flutter doctor` reports no issues for the Android toolchain.
- For release builds, ensure a signing configuration is available. The existing Gradle fallback uses the debug keystore when no release keystore is configured; this is acceptable for internal distribution but must be replaced with a production keystore before store release.

### `Artifact not found`

The Flutter build did not produce the expected output path. Check the full build log for errors. The expected paths are:

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`
