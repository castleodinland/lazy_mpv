@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

cd /D "%~dp0"

echo ============================================
echo  mpv-lazy release builder
echo ============================================
echo.

if not exist "python.exe" (
    echo [ERROR] python.exe not found in current directory.
    pause
    exit /b 1
)
if not exist "7z.exe" (
    echo [ERROR] 7z.exe not found in current directory.
    pause
    exit /b 1
)
if not exist "tools\build_release.py" (
    echo [ERROR] tools\build_release.py not found.
    pause
    exit /b 1
)

echo Building, please wait...
echo.

python.exe tools\build_release.py
if errorlevel 1 (
    echo.
    echo [ERROR] Build failed.
    pause
    exit /b 1
)

echo.
set /p TAG=<release\tag.txt
echo ============================================
echo  Done!
echo  Installer: release\mpv-lazy-setup.exe
echo  Version tag: %TAG%
echo ============================================
echo.
pause
