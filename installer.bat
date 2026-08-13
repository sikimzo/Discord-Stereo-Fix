@echo off
chcp 65001 >nul
title SIKIMZO STEREO INSTALLER V3.6.1
setlocal EnableDelayedExpansion

set CURRENT_VERSION=V3.6.1

:: ================ ANSI COLORS ================
set ESC=
set RESET=%ESC%[0m
set RED=%ESC%[31m
set GREEN=%ESC%[32m
set YELLOW=%ESC%[33m
set CYAN=%ESC%[36m

:MENU
cls
echo %CYAN%===============================%RESET%
echo %CYAN%^|   STEREO INSTALLER %CURRENT_VERSION%   ^|%RESET%
echo %CYAN%^|       made by sikimzo       ^|%RESET%
echo %CYAN%===============================%RESET%
echo.
echo Select Your Discord For Installation
echo.
echo [1] Discord
echo [2] Discord PTB
echo [3] Discord Canary
echo.
set /p choice=Enter Your Choice: 

if "%choice%"=="1" set BASE=%LOCALAPPDATA%\Discord& set EXE=discord.exe& goto INSTALL
if "%choice%"=="2" set BASE=%LOCALAPPDATA%\DiscordPTB& set EXE=discordptb.exe& goto INSTALL
if "%choice%"=="3" set BASE=%LOCALAPPDATA%\DiscordCanary& set EXE=discordcanary.exe& goto INSTALL
if "%choice%"=="4" goto RESTORE_MENU

:: ================= INSTALL =================
:INSTALL
cls
taskkill /f /im %EXE% >nul 2>&1

for /d %%A in ("%BASE%\app-*") do set APP=%%A
for /d %%M in ("%APP%\modules\discord_voice-*") do set VOICE=%%M

if not defined VOICE (
    echo %RED%discord_voice not found
    timeout /t 3 /nobreak >NUL
    exit
)

set TARGET=%VOICE%\discord_voice

:: ================== BACKUP ==================
if not exist "%TARGET%" (
    echo discord_voice folder not found.
    pause
    exit /b
)

if exist "%TARGET%\backup_*.zip" (
    echo Backup already exists, skipping...
) else (
    echo %GREEN%[+] Creating backup...%RESET%

    powershell -NoProfile -Command ^
    "Compress-Archive -Path '%TARGET%\*' -DestinationPath '%TARGET%\backup_%DATE:/=-%_%TIME::=-%.zip' -Force"
)

:: Clean
for %%F in ("%TARGET%\*") do if /I not "%%~xF"==".zip" del /f /q "%%F" >nul 2>&1

:: Copy modules
xcopy "%~dp0modules\*" "%TARGET%\" /E /H /Y >nul

echo Installation completed
timeout /t 3 /nobreak >NUL
exit
