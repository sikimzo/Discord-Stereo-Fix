@echo off
chcp 65001 >nul
title SIKIMZO STEREO INSTALLER V3.7.0
setlocal EnableExtensions EnableDelayedExpansion

set "CURRENT_VERSION=V3.7.0"

:: ================ ANSI COLORS ================
for /F "delims=" %%E in ('echo prompt $E^| cmd') do set "ESC=%%E"
set "RESET=%ESC%[0m"
set "RED=%ESC%[31m"
set "GREEN=%ESC%[32m"
set "YELLOW=%ESC%[33m"
set "CYAN=%ESC%[36m"
set "WHITE=%ESC%[97m"
set "GRAY=%ESC%[90m"

:MENU
cls
echo %CYAN%===============================%RESET%
echo %CYAN%^|   STEREO INSTALLER %CURRENT_VERSION%   ^|%RESET%
echo %CYAN%^|       made by sikimzo       ^|%RESET%
echo %CYAN%===============================%RESET%
echo.
echo %WHITE%Select Your Discord%RESET%
echo.
echo %CYAN%[1]%RESET% Discord
echo %CYAN%[2]%RESET% Discord PTB
echo %CYAN%[3]%RESET% Discord Canary
echo %CYAN%[4]%RESET% Backup
echo.
set "choice="
set /p "choice=Enter Your Choice: "

if "!choice!"=="1" (
    set "BASE=%LOCALAPPDATA%\Discord"
    set "EXE=discord.exe"
    set "DISCORD_NAME=Discord"
    goto INSTALL
)
if "!choice!"=="2" (
    set "BASE=%LOCALAPPDATA%\DiscordPTB"
    set "EXE=discordptb.exe"
    set "DISCORD_NAME=Discord PTB"
    goto INSTALL
)
if "!choice!"=="3" (
    set "BASE=%LOCALAPPDATA%\DiscordCanary"
    set "EXE=discordcanary.exe"
    set "DISCORD_NAME=Discord Canary"
    goto INSTALL
)
if "!choice!"=="4" goto BACKUP_MENU
goto MENU

:: ================= INSTALL =================
:INSTALL
cls
echo %CYAN%[i] INSTALL STEREO %CURRENT_VERSION%
echo %CYAN%[i] FOR %DISCORD_NAME%
echo.

set "APP="
set "VOICE="
set "TARGET="

:: Check whether Discord was already running.
tasklist /FI "IMAGENAME eq !EXE!" 2>nul | find /I "!EXE!" >nul
if errorlevel 1 (
    set "WAS_RUNNING=0"
) else (
    set "WAS_RUNNING=1"
)

if "!WAS_RUNNING!"=="1" (
    echo %YELLOW%[!] !DISCORD_NAME! is running. Closing it...%RESET%
    taskkill /f /im "!EXE!" >nul 2>&1
    timeout /t 1 /nobreak >nul
)

for /d %%A in ("!BASE!\app-*") do set "APP=%%~fA"
if not defined APP (
    echo %RED%discord app folder not found.%RESET%
    if "!WAS_RUNNING!"=="1" call :START_DISCORD
    timeout /t 3 /nobreak >nul
    goto MENU
)

for /d %%M in ("!APP!\modules\discord_voice-*") do set "VOICE=%%~fM"
if not defined VOICE (
    echo %RED%discord_voice not found.%RESET%
    if "!WAS_RUNNING!"=="1" call :START_DISCORD
    timeout /t 3 /nobreak >nul
    goto MENU
)

set "TARGET=!VOICE!\discord_voice"

if not exist "!TARGET!\" (
    echo %RED%discord_voice folder not found.%RESET%
    if "!WAS_RUNNING!"=="1" call :START_DISCORD
    timeout /t 3 /nobreak >nul
    goto MENU
)

:: ================== BACKUP ==================
set "EXISTING_BACKUP="
for %%Z in ("!TARGET!\backup_*.zip") do if exist "%%~fZ" set "EXISTING_BACKUP=%%~fZ"

if defined EXISTING_BACKUP (
    echo %YELLOW%[!] Backup already exists, skipping...%RESET%
) else (
    echo %GREEN%[+] Creating backup...%RESET%
    for /f "delims=" %%T in ('powershell -NoProfile -Command "Get-Date -Format ''yyyy-MM-dd_HH-mm-ss''"') do set "STAMP=%%T"
    powershell -NoProfile -Command ^
    "Compress-Archive -Path '!TARGET!\*' -DestinationPath '!TARGET!\backup_!STAMP!.zip' -Force"
    if errorlevel 1 (
        echo %RED%[X] Failed to create backup.%RESET%
        if "!WAS_RUNNING!"=="1" call :START_DISCORD
        timeout /t 3 /nobreak >nul
        goto MENU
    )
)

:: Clean old files but preserve ZIP backups.
echo %GREEN%[+] Cleaning old module files...%RESET%
for /d %%D in ("!TARGET!\*") do rd /s /q "%%~fD" >nul 2>&1
for %%F in ("!TARGET!\*") do if /I not "%%~xF"==".zip" del /f /q "%%~fF" >nul 2>&1

:: Copy modules.
echo %GREEN%[+] Installing modules...%RESET%
xcopy "%~dp0modules\*" "!TARGET!\" /E /H /I /Y >nul
if errorlevel 1 (
    echo %RED%[X] Installation failed.%RESET%
    if "!WAS_RUNNING!"=="1" call :START_DISCORD
    timeout /t 3 /nobreak >nul
    goto MENU
)

echo.
echo %GREEN%[+] Installation completed.%RESET%

if "!WAS_RUNNING!"=="1" (
    echo %GREEN%[+] Starting !DISCORD_NAME!...%RESET%
    call :START_DISCORD
)

timeout /t 3 /nobreak >nul
goto MENU

:: ================= BACKUP MENU =================
:BACKUP_MENU
cls
echo %CYAN%===============================%RESET%
echo %CYAN%^|          BACKUP MENU        ^|%RESET%
echo %CYAN%===============================%RESET%
echo.
echo %WHITE%Select Your Discord%RESET%
echo.
echo %CYAN%[1]%RESET% Discord
echo %CYAN%[2]%RESET% Discord PTB
echo %CYAN%[3]%RESET% Discord Canary
echo.
echo %GRAY%-------------------------------%RESET%
echo %CYAN%[B]%RESET% Back
echo.
set "backupChoice="
set /p "backupChoice=Enter Your Choice: "

if /I "!backupChoice!"=="B" goto MENU

if "!backupChoice!"=="1" (
    set "BASE=%LOCALAPPDATA%\Discord"
    set "EXE=discord.exe"
    set "DISCORD_NAME=Discord"
    goto BACKUP_LIST
)
if "!backupChoice!"=="2" (
    set "BASE=%LOCALAPPDATA%\DiscordPTB"
    set "EXE=discordptb.exe"
    set "DISCORD_NAME=Discord PTB"
    goto BACKUP_LIST
)
if "!backupChoice!"=="3" (
    set "BASE=%LOCALAPPDATA%\DiscordCanary"
    set "EXE=discordcanary.exe"
    set "DISCORD_NAME=Discord Canary"
    goto BACKUP_LIST
)
goto BACKUP_MENU

:: ================= BACKUP LIST =================
:BACKUP_LIST
cls
echo %CYAN%===============================%RESET%
echo %CYAN%^|       BACKUP FILES          ^|%RESET%
echo %CYAN%===============================%RESET%
echo.
echo %GRAY%Discord:%RESET% %WHITE%!DISCORD_NAME!%RESET%
echo.

set "APP="
set "VOICE="
set "TARGET="

for /d %%A in ("!BASE!\app-*") do set "APP=%%~fA"
if not defined APP (
    echo %RED%discord app folder not found.%RESET%
    timeout /t 3 /nobreak >nul
    goto BACKUP_MENU
)

for /d %%M in ("!APP!\modules\discord_voice-*") do set "VOICE=%%~fM"
if not defined VOICE (
    echo %RED%discord_voice not found.%RESET%
    timeout /t 3 /nobreak >nul
    goto BACKUP_MENU
)

set "TARGET=!VOICE!\discord_voice"

if not exist "!TARGET!\" (
    echo %RED%discord_voice folder not found.%RESET%
    timeout /t 3 /nobreak >nul
    goto BACKUP_MENU
)

set /a ZIP_COUNT=0
for %%Z in ("!TARGET!\*.zip") do (
    if exist "%%~fZ" (
        set /a ZIP_COUNT+=1
        set "ZIP_!ZIP_COUNT!=%%~fZ"
    )
)

if !ZIP_COUNT! EQU 0 (
    echo %YELLOW%No ZIP backups found inside discord_voice.%RESET%
    echo.
    echo %GRAY%Press any key to return...%RESET%
    pause >nul
    goto BACKUP_MENU
)

echo %WHITE%Available ZIP backups:%RESET%
echo.

for /L %%N in (1,1,!ZIP_COUNT!) do (
    for %%Z in ("!ZIP_%%N!") do echo %CYAN%[%%N]%RESET% %%~nxZ
)

echo.
echo %GRAY%-------------------------------%RESET%
echo %CYAN%[B]%RESET% Back
echo.
set "restoreChoice="
set /p "restoreChoice=Enter Your Choice: "

if /I "!restoreChoice!"=="B" goto BACKUP_MENU

set "SELECTED_ZIP="
for /L %%N in (1,1,!ZIP_COUNT!) do (
    if "!restoreChoice!"=="%%N" set "SELECTED_ZIP=!ZIP_%%N!"
)

if not defined SELECTED_ZIP (
    echo %RED%Invalid choice.%RESET%
    timeout /t 2 /nobreak >nul
    goto BACKUP_LIST
)

cls
echo %CYAN%===============================%RESET%
echo %CYAN%^|       RESTORE BACKUP        ^|%RESET%
echo %CYAN%===============================%RESET%
echo.

for %%Z in ("!SELECTED_ZIP!") do echo %WHITE%Selected:%RESET% %%~nxZ
echo.

:: Check whether Discord was already running.
tasklist /FI "IMAGENAME eq !EXE!" 2>nul | find /I "!EXE!" >nul
if errorlevel 1 (
    set "WAS_RUNNING=0"
) else (
    set "WAS_RUNNING=1"
)

if "!WAS_RUNNING!"=="1" (
    echo %YELLOW%[!] !DISCORD_NAME! is running. Closing it...%RESET%
    taskkill /f /im "!EXE!" >nul 2>&1
    timeout /t 1 /nobreak >nul
)

echo %GREEN%[+] Extracting backup...%RESET%
powershell -NoProfile -Command ^
"Expand-Archive -LiteralPath '!SELECTED_ZIP!' -DestinationPath '!TARGET!' -Force"
if errorlevel 1 (
    echo %RED%[X] Failed to extract backup.%RESET%
) else (
    echo %GREEN%[+] Backup restored successfully.%RESET%
)

if "!WAS_RUNNING!"=="1" (
    echo %GREEN%[+] Starting !DISCORD_NAME!...%RESET%
    call :START_DISCORD
)

echo.
timeout /t 3 /nobreak >nul
goto BACKUP_MENU

:: ================= START DISCORD =================
:START_DISCORD
if exist "!BASE!\Update.exe" (
    start "" "!BASE!\Update.exe" --processStart "!EXE!" >nul 2>&1
    exit /b 0
)

if exist "!BASE!\!EXE!" (
    start "" "!BASE!\!EXE!" >nul 2>&1
    exit /b 0
)

exit /b 1
