@echo off
setlocal enabledelayedexpansion

echo =======================================================
echo   Bhagavad Gita As It Is - Build and Deploy APK
echo =======================================================

set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
set "ANDROID_HOME=C:\Android\Sdk"

echo [1/3] Compiling fresh release APK...
call "C:\flutter\bin\flutter.bat" build apk --release < nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter build failed with exit code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

echo [2/3] Copying updated APK to Website downloads directory...
if not exist "Gita_website\public\downloads" mkdir "Gita_website\public\downloads"
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "Gita_website\public\downloads\bhagavad-gita-as-it-is.apk"

echo [3/3] Verification:
powershell -NoProfile -Command "Get-Item 'Gita_website\public\downloads\bhagavad-gita-as-it-is.apk' | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize"

echo =======================================================
echo   SUCCESS: Updated APK is now live on the website!
echo   Download Link: http://localhost:3000/download/android
echo =======================================================

