@echo off
setlocal enabledelayedexpansion
title MoonGride - Lunar Mission Server (Multi-threaded)

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
    pause
    exit /b 1
)

if exist "%SCRIPT_DIR%tools\bin" (
    set "PATH=%SCRIPT_DIR%tools\bin;!PATH!"
)

set "PUBLIC_DIR=%SCRIPT_DIR%test\lunar-south-pole-backend\public"
if not exist "!PUBLIC_DIR!" (
    if exist "%SCRIPT_DIR%public" (
        set "PUBLIC_DIR=%SCRIPT_DIR%public"
    )
)

set "PORT=8000"

echo =======================================================
echo          MOONGRIDE MULTI-THREADED SERVER
echo =======================================================
echo [OK] PHP Binary:      !PHP_BIN!
echo [OK] Web Root:        !PUBLIC_DIR!
echo [OK] Local Port:      !PORT!
echo [OK] Workers:         4 (PHP_CLI_SERVER_WORKERS=4)
echo.
echo Starting MoonGride web server on http://127.0.0.1:!PORT! ...
echo.

start "" cmd /c "timeout /t 2 /nobreak >nul & start http://127.0.0.1:%PORT%/index.html"

if exist "%SCRIPT_DIR%php\php.ini" (
    "!PHP_BIN!" -c "%SCRIPT_DIR%php\php.ini" -S 127.0.0.1:%PORT% -t "!PUBLIC_DIR!"
) else (
    "!PHP_BIN!" -S 127.0.0.1:%PORT% -t "!PUBLIC_DIR!"
)

pause
