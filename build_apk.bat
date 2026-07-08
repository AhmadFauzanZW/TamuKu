@echo off
setlocal

echo Building TamuKu Production APK

if "%API_KEY%"=="" (
    echo ERROR: API_KEY not set. Usage: set API_KEY=xxx ^& build_apk.bat
    exit /b 1
)

if "%S3_ACCESS_KEY%"=="" (
    echo ERROR: S3_ACCESS_KEY not set.
    exit /b 1
)

if "%S3_SECRET_KEY%"=="" (
    echo ERROR: S3_SECRET_KEY not set.
    exit /b 1
)

flutter clean
flutter pub get

flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols ^
    --dart-define=API_KEY=%API_KEY% ^
    --dart-define=S3_ACCESS_KEY=%S3_ACCESS_KEY% ^
    --dart-define=S3_SECRET_KEY=%S3_SECRET_KEY%

echo Build complete: build\app\outputs\flutter-apk\app-release.apk
