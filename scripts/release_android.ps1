#Requires -Version 5.1
<#
.SYNOPSIS
    Builds a Flutter Android release artifact and uploads it to Firebase App Distribution.

.DESCRIPTION
    This script builds either a release APK or AAB and distributes it via the Firebase CLI.
    Configuration is read from environment variables and optionally from a local .env file.

.PARAMETER BuildType
    Type of artifact to build and distribute: "apk" (default) or "aab".

.PARAMETER ReleaseNotes
    Release notes to attach to the distributed build.

.PARAMETER Groups
    Comma-separated list of Firebase App Distribution tester group names.
    Defaults to the value of the FIREBASE_TESTER_GROUPS environment variable.

.EXAMPLE
    .\scripts\release_android.ps1 -BuildType apk -ReleaseNotes "Bug fixes and performance improvements" -Groups "qa-team"

.EXAMPLE
    .\scripts\release_android.ps1 -BuildType aab -ReleaseNotes "Internal beta"
#>
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("apk", "aab")]
    [string]$BuildType = "apk",

    [Parameter(Mandatory = $false)]
    [string]$ReleaseNotes = "",

    [Parameter(Mandatory = $false)]
    [string]$Groups = $env:FIREBASE_TESTER_GROUPS
)

$ErrorActionPreference = "Stop"

# Move to the project root (parent of the scripts directory).
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Resolve-Path (Join-Path $scriptDir "..")).Path

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-ErrorAndExit {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    exit 1
}

# Load environment variables from .env if it exists, without overwriting existing env vars.
function Import-DotEnv {
    param([string]$Path)
    if (Test-Path $Path) {
        Write-Info "Loading environment variables from $Path"
        Get-Content $Path | ForEach-Object {
            $line = $_.Trim()
            if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#")) {
                return
            }
            $separatorIndex = $line.IndexOf("=")
            if ($separatorIndex -le 0) {
                return
            }
            $name = $line.Substring(0, $separatorIndex).Trim()
            $value = $line.Substring($separatorIndex + 1).Trim()
            # Remove surrounding quotes if present.
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or
                ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            if (-not [Environment]::GetEnvironmentVariable($name)) {
                [Environment]::SetEnvironmentVariable($name, $value, "Process") | Out-Null
            }
        }
    }
}

Import-DotEnv ".env"

function Get-RequiredEnvironmentValue {
    param([string]$Name)

    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        Write-ErrorAndExit "$Name is not set. Add it to .env or set it in the terminal environment."
    }
    return $value
}

# Validate required tooling.
foreach ($tool in @("flutter", "firebase")) {
    $found = Get-Command $tool -ErrorAction SilentlyContinue
    if (-not $found) {
        Write-ErrorAndExit "$tool command not found. Make sure it is installed and on PATH."
    }
}

# Resolve configuration.
$appId = $env:FIREBASE_ANDROID_APP_ID
if ([string]::IsNullOrWhiteSpace($appId)) {
    Write-ErrorAndExit "FIREBASE_ANDROID_APP_ID is not set. Add it to .env or set it as an environment variable."
}

if ([string]::IsNullOrWhiteSpace($Groups)) {
    $Groups = $env:FIREBASE_TESTER_GROUPS
}

if ([string]::IsNullOrWhiteSpace($Groups)) {
    Write-ErrorAndExit "No tester groups provided. Set FIREBASE_TESTER_GROUPS in .env or pass -Groups."
}

$projectId = $env:FIREBASE_PROJECT_ID
$hostValue = Get-RequiredEnvironmentValue "HOST"
$baseUrlValue = Get-RequiredEnvironmentValue "BASEURL"
$appEnvironment = if ([string]::IsNullOrWhiteSpace($env:APP_ENV)) {
    "production"
}
else {
    $env:APP_ENV
}

# Only these public runtime values are forwarded to the Flutter compiler.
# Never pass the entire .env file because it may also contain CI credentials.
$dartDefineArgs = @(
    "--dart-define=HOST=$hostValue",
    "--dart-define=BASEURL=$baseUrlValue",
    "--dart-define=APP_ENV=$appEnvironment"
)
if (-not [string]::IsNullOrWhiteSpace($env:LATEST_VERSION)) {
    $dartDefineArgs += "--dart-define=LATEST_VERSION=$env:LATEST_VERSION"
}

# Determine build command and artifact path.
if ($BuildType -eq "apk") {
    $buildArgs = @("build", "apk", "--release") + $dartDefineArgs
    $artifact = "build/app/outputs/flutter-apk/app-release.apk"
}
else {
    $buildArgs = @("build", "appbundle", "--release") + $dartDefineArgs
    $artifact = "build/app/outputs/bundle/release/app-release.aab"
}

# Build the release artifact.
Write-Info "Building Flutter $BuildType release..."
& flutter @buildArgs
if ($LASTEXITCODE -ne 0) {
    Write-ErrorAndExit "Flutter build failed with exit code $LASTEXITCODE."
}

if (-not (Test-Path $artifact)) {
    Write-ErrorAndExit "Expected artifact not found: $artifact"
}

# Assemble Firebase CLI arguments.
$firebaseArgs = @(
    "appdistribution:distribute",
    $artifact,
    "--app", $appId,
    "--groups", $Groups
)
if (-not [string]::IsNullOrWhiteSpace($projectId)) {
    $firebaseArgs += @("--project", $projectId)
}
if (-not [string]::IsNullOrWhiteSpace($ReleaseNotes)) {
    $firebaseArgs += @("--release-notes", $ReleaseNotes)
}

# Distribute.
Write-Info "Uploading $artifact to Firebase App Distribution..."
Write-Info "App ID: $appId"
Write-Info "Tester groups: $Groups"
& firebase @firebaseArgs
if ($LASTEXITCODE -ne 0) {
    Write-ErrorAndExit "Firebase App Distribution upload failed with exit code $LASTEXITCODE."
}

Write-Info "Release uploaded successfully."
