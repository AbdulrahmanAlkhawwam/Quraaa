#Requires -Version 5.1
<#
.SYNOPSIS
    Builds a distributable Android release containing every supported ABI.

.DESCRIPTION
    Loads public backend configuration from .env/process variables, passes it
    to Dart at compile time, builds a universal APK or AAB, validates that the
    Flutter engine exists for every supported ABI, and copies the verified
    artifact to build/distributions.

.PARAMETER BuildType
    "apk" (default) or "aab".
#>
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("apk", "aab")]
    [string]$BuildType = "apk"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path
Set-Location $projectRoot

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Fail-Build {
    param([string]$Message)
    throw "[ERROR] $Message"
}

function Import-DotEnv {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    Get-Content -LiteralPath $Path | ForEach-Object {
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
        if (($value.StartsWith('"') -and $value.EndsWith('"')) -or
            ($value.StartsWith("'") -and $value.EndsWith("'"))) {
            $value = $value.Substring(1, $value.Length - 2)
        }

        if (-not [Environment]::GetEnvironmentVariable($name)) {
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

function Assert-RequiredValue {
    param([string]$Name)

    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        Fail-Build "$Name is required. Add it to .env or the process environment."
    }
}

function Assert-UniversalFlutterArtifact {
    param(
        [string]$Artifact,
        [string]$Prefix
    )

    $jar = Get-Command "jar" -ErrorAction SilentlyContinue
    if (-not $jar) {
        Fail-Build "jar command not found; a JDK is required to verify the release artifact."
    }

    $entries = @(& $jar.Source tf $Artifact)
    if ($LASTEXITCODE -ne 0) {
        Fail-Build "Unable to inspect release artifact: $Artifact"
    }

    $missingEntries = @()
    foreach ($abi in @("armeabi-v7a", "arm64-v8a", "x86_64")) {
        foreach ($library in @("libapp.so", "libflutter.so")) {
            $requiredEntry = "$Prefix/$abi/$library"
            if ($entries -notcontains $requiredEntry) {
                $missingEntries += $requiredEntry
            }
        }
    }

    if ($missingEntries.Count -gt 0) {
        Fail-Build "Release is not universal. Missing: $($missingEntries -join ', ')"
    }
}

Import-DotEnv (Join-Path $projectRoot ".env")
Assert-RequiredValue "HOST"
Assert-RequiredValue "BASEURL"

$flutter = Get-Command "flutter" -ErrorAction SilentlyContinue
if (-not $flutter) {
    Fail-Build "flutter command not found."
}

$targetPlatforms = "android-arm,android-arm64,android-x64"
$buildCommand = if ($BuildType -eq "apk") { "apk" } else { "appbundle" }
$artifact = if ($BuildType -eq "apk") {
    Join-Path $projectRoot "build/app/outputs/flutter-apk/app-release.apk"
} else {
    Join-Path $projectRoot "build/app/outputs/bundle/release/app-release.aab"
}

$buildArgs = @(
    "build",
    $buildCommand,
    "--release",
    "--target-platform=$targetPlatforms",
    "--dart-define=APP_ENV=production",
    "--dart-define=HOST=$env:HOST",
    "--dart-define=BASEURL=$env:BASEURL"
)
if (-not [string]::IsNullOrWhiteSpace($env:LATEST_VERSION)) {
    $buildArgs += "--dart-define=LATEST_VERSION=$env:LATEST_VERSION"
}

if (-not [string]::IsNullOrWhiteSpace($env:TELEGRAM_BOT_TOKEN)) {
    $buildArgs += "--dart-define=TELEGRAM_BOT_TOKEN=$env:TELEGRAM_BOT_TOKEN"
}
if (-not [string]::IsNullOrWhiteSpace($env:TELEGRAM_CHAT_ID)) {
    $buildArgs += "--dart-define=TELEGRAM_CHAT_ID=$env:TELEGRAM_CHAT_ID"
}
Write-Info "Building universal Flutter $BuildType release..."
& $flutter.Source @buildArgs
if ($LASTEXITCODE -ne 0) {
    Fail-Build "Flutter build failed with exit code $LASTEXITCODE."
}
if (-not (Test-Path -LiteralPath $artifact)) {
    Fail-Build "Expected artifact not found: $artifact"
}

$entryPrefix = if ($BuildType -eq "apk") { "lib" } else { "base/lib" }
Assert-UniversalFlutterArtifact -Artifact $artifact -Prefix $entryPrefix

$distributionDirectory = Join-Path $projectRoot "build/distributions"
New-Item -ItemType Directory -Path $distributionDirectory -Force | Out-Null
$distributionName = if ($BuildType -eq "apk") {
    "quraaa-universal-release.apk"
} else {
    "quraaa-release.aab"
}
$distributionArtifact = Join-Path $distributionDirectory $distributionName
Copy-Item -LiteralPath $artifact -Destination $distributionArtifact -Force

if (-not (Test-Path -LiteralPath "android/key.properties")) {
    Write-Warning "No release keystore is configured; this internal build uses the local debug signing key."
}

$sizeMb = [Math]::Round((Get-Item -LiteralPath $distributionArtifact).Length / 1MB, 2)
Write-Info "Verified artifact ($sizeMb MB): $distributionArtifact"

