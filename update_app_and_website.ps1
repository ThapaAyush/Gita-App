# Bhagavad Gita As It Is - Automated Build & Website Deployment Script
$ErrorActionPreference = "Stop"

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  Bhagavad Gita As It Is - Build & Deploy APK to Website" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan

$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:ANDROID_HOME = "C:\Android\Sdk"

Write-Host "`n[1/3] Building fresh release APK..." -ForegroundColor Yellow
$flutterBin = "C:\flutter\bin\flutter.bat"
if (-not (Test-Path $flutterBin)) {
    $flutterBin = "flutter"
}

& $flutterBin build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed with exit code $LASTEXITCODE"
}

Write-Host "`n[2/3] Deploying updated APK to website downloads..." -ForegroundColor Yellow
$srcApk = "build\app\outputs\flutter-apk\app-release.apk"
$destDir = "Gita_website\public\downloads"
$destApk = "$destDir\bhagavad-gita-as-it-is.apk"

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

Copy-Item $srcApk $destApk -Force

Write-Host "`n[3/3] Deployment Verification:" -ForegroundColor Green
Get-Item $destApk | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  SUCCESS: The updated APK is now deployed to the website!" -ForegroundColor Green
Write-Host "  Download URL: http://localhost:3000/download/android" -ForegroundColor White
Write-Host "=======================================================" -ForegroundColor Cyan

