@echo off
setlocal enabledelayedexpansion
title MoonGride - Lunar Mission Control Launcher

echo =======================================================
echo          MOONGRIDE LOCAL ENVIRONMENT LAUNCHER
echo =======================================================
echo.

:: Detect workspace root and PHP binary
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

set "PHP_CLI_SERVER_WORKERS=4"

set "PHP_BIN="
if exist "%SCRIPT_DIR%php\php.exe" (
    set "PHP_BIN=%SCRIPT_DIR%php\php.exe"
) else (
    where php >nul 2>&1
    if not errorlevel 1 (
        set "PHP_BIN=php"
    )
)

if "%PHP_BIN%"=="" (
    echo [ERROR] PHP executable was not found!
    echo Please install PHP 8.2+ or place portable PHP in "%SCRIPT_DIR%php\".
    pause
    exit /b 1
)

:: Detect Python
set "PYTHON_BIN="
where python >nul 2>&1
if not errorlevel 1 (
    set "PYTHON_BIN=python"
)

if "%PYTHON_BIN%"=="" (
    echo [WARNING] Python was not found in PATH.
    echo NASA LOLA DEM GeoTIFF extraction fallback requires Python with Pillow.
)

:: Set GDAL tools path
if exist "%SCRIPT_DIR%tools\bin" (
    set "GDAL_BIN_DIR=%SCRIPT_DIR%tools\bin"
    set "PATH=%SCRIPT_DIR%tools\bin;!PATH!"
)

:: Determine public directory
set "PUBLIC_DIR=%SCRIPT_DIR%test\lunar-south-pole-backend\public"
if not exist "!PUBLIC_DIR!" (
    if exist "%SCRIPT_DIR%public" (
        set "PUBLIC_DIR=%SCRIPT_DIR%public"
    )
)

set "PORT=8000"

echo [OK] PHP Binary:      !PHP_BIN!
echo [OK] GDAL Tools:      !GDAL_BIN_DIR!
echo [OK] Web Root:        !PUBLIC_DIR!
echo [OK] Local Port:      !PORT!
echo.
echo Starting MoonGride web server on http://127.0.0.1:!PORT! ...
echo Press Ctrl+C in this window to stop the server.
echo.

:: Open default browser after 2 seconds in background
start "" cmd /c "timeout /t 2 /nobreak >nul & start http://127.0.0.1:%PORT%/index.html"

:: Start PHP development server with project configuration
if exist "%SCRIPT_DIR%php\php.ini" (
    "!PHP_BIN!" -c "%SCRIPT_DIR%php\php.ini" -S 127.0.0.1:%PORT% -t "!PUBLIC_DIR!"
) else (
    "!PHP_BIN!" -S 127.0.0.1:%PORT% -t "!PUBLIC_DIR!"
)

pause
