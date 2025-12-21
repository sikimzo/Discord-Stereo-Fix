@echo off
chcp 65001 >nul
title SIKIMZO STEREO INSTALLER V2.0.0
setlocal EnableDelayedExpansion

set CURRENT_VERSION=V2.0.0
set UPDATE_MSG=

:: ================= ANSI COLORS =================
set ESC=
set RESET=%ESC%[0m
set RED=%ESC%[31m
set GREEN=%ESC%[32m
set YELLOW=%ESC%[33m
set CYAN=%ESC%[36m


:MENU
cls
echo %CYAN%===============================%RESET%
echo %CYAN%^|   STEREO INSTALLER V2.0.0   ^|%RESET%
echo %CYAN%^|        made by sikimzo      ^|%RESET%
echo %CYAN%===============================%RESET%
echo.
echo Select Your Discord For Installation
echo [1] Discord
echo [2] Discord PTB
echo [3] Discord Canary
echo [4] Uninstall Stereo
echo.
set /p choice=Enter Your Choice: 

if "%choice%"=="1" set BASE=%LOCALAPPDATA%\Discord& set EXE=discord.exe& goto INSTALL
if "%choice%"=="2" set BASE=%LOCALAPPDATA%\DiscordPTB& set EXE=discordptb.exe& goto INSTALL
if "%choice%"=="3" set BASE=%LOCALAPPDATA%\DiscordCanary& set EXE=discordcanary.exe& goto INSTALL
if "%choice%"=="4" goto UNINSTALL

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
set FFMPEG=%APP%\ffmpeg.dll

:: Backup
set HAS_BACKUP=0
for %%B in ("%TARGET%\backup_*.zip") do set HAS_BACKUP=1

if "%HAS_BACKUP%"=="0" (
    echo %GREEN%[+] Creating backup...%RESET%
    powershell -command ^
    "Compress-Archive '%TARGET%\*','%FFMPEG%' '%TARGET%\backup_%DATE:/=-%_%TIME::=-%.zip'"
) else (
    echo %YELLOW%Backup already exists, skipping backup%RESET%
)


:: Clean
for %%F in ("%TARGET%\*") do if /I not "%%~xF"==".zip" del /f /q "%%F" >nul 2>&1

:: Copy modules
xcopy "%~dp0modules\*" "%TARGET%\" /E /H /Y >nul

:: Replace ffmpeg
if exist "%~dp0ffmpeg.dll" copy /Y "%~dp0ffmpeg.dll" "%FFMPEG%" >nul

echo Installation completed
timeout /t 3 /nobreak >NUL
exit

:: ================= UNINSTALL =================
:UNINSTALL
cls
echo Select Discord To Uninstall Stereo From
echo [1] Discord
echo [2] Discord PTB
echo [3] Discord Canary
set /p uchoice=Choice: 

if "%uchoice%"=="1" set BASE=%LOCALAPPDATA%\Discord& set EXE=discord.exe
if "%uchoice%"=="2" set BASE=%LOCALAPPDATA%\DiscordPTB& set EXE=discordptb.exe
if "%uchoice%"=="3" set BASE=%LOCALAPPDATA%\DiscordCanary& set EXE=discordcanary.exe

taskkill /f /im %EXE% >nul 2>&1

for /d %%A in ("%BASE%\app-*") do set APP=%%A
for /d %%M in ("%APP%\modules\discord_voice-*") do set VOICE=%%M
set TARGET=%VOICE%\discord_voice

set TMP=%TEMP%\stereo_uninstall
rmdir /s /q "%TMP%" >nul 2>&1
mkdir "%TMP%"

powershell -command ^
"Invoke-WebRequest https://github.com/sikimzo/stereo-uninstall/archive/refs/heads/main.zip -OutFile '%TMP%\u.zip'"
powershell -command ^
"Expand-Archive '%TMP%\u.zip' '%TMP%'"

xcopy "%TMP%\stereo-uninstall-main\*" "%TARGET%\" /E /H /Y >nul

echo Stereo uninstalled
timeout /t 3 /nobreak >NUL
exit
