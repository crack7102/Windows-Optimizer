::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul

:: ===============================
::       UNINSTALL APPS
:: ===============================

cls
echo ============================================
echo        REMOVE PREINSTALLED APPS
echo ============================================
echo.

set "removerDir=%~dp0Remover"

:: =======================================
::            WINDOWS STORE APP
:: =======================================
echo Opening PowerShell in a separate window to remove Windows Store apps.
timeout /t 3 >nul
start /wait powershell -ExecutionPolicy Bypass -File "%removerDir%\DisinstallaApp.ps1"
timeout /t 2 >nul

:: =======================================
::            HIBIT UNINSTALLER
:: =======================================
echo Opening HiBit Uninstaller to remove other apps, including system apps.
timeout /t 3 >nul
start /wait "" "%removerDir%\HiBit Uninstaller.exe" || exit /b 0
timeout /t 2 >nul

:: =======================================
::       RIMOZIONE MICROSOFT EDGE
:: =======================================
echo Opening program to remove Microsoft Edge.
timeout /t 3 >nul
chcp 437 >nul 2>&1
powershell -NoProfile -Command ^
"[void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $r = [System.Windows.Forms.MessageBox]::Show('Do you want to remove Microsoft Edge?','Edge Removal','YesNo','Question'); if($r -eq 'Yes'){exit 0}else{exit 1}"
set "EDGE_CHOICE=%errorlevel%"
if "%EDGE_CHOICE%"=="" set "EDGE_CHOICE=1"
chcp 65001 >nul 2>&1

if "%EDGE_CHOICE%"=="0" (
    taskkill /IM msedge.exe /F /T >nul 2>&1
    taskkill /IM msedgewebview2.exe /F /T >nul 2>&1
    taskkill /IM MicrosoftEdgeUpdate.exe /F /T >nul 2>&1
    taskkill /IM edgeupdate.exe /F /T >nul 2>&1
    taskkill /IM setup.exe /F /T >nul 2>&1

    if exist "%removerDir%\Edge Remover.exe" (
        start /wait "" "%removerDir%\Edge Remover.exe"
    )
) else (
    echo Edge removal skipped.
)
timeout /t 2 >nul

:: =======================================
::       RIMOZIONE WINDOWS DEFENDER
:: =======================================
echo Opening program to remove Windows Defender.
timeout /t 3 >nul
chcp 437 >nul 2>&1
powershell -NoProfile -Command ^
"[void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $r = [System.Windows.Forms.MessageBox]::Show('Do you want to completely remove Windows Defender?','Windows Defender Removal','YesNo','Question'); if($r -eq 'Yes'){exit 0}else{exit 1}"
set "DEFENDER_CHOICE=%errorlevel%"
if "%DEFENDER_CHOICE%"=="" set "DEFENDER_CHOICE=1"
chcp 65001 >nul 2>&1

if "%DEFENDER_CHOICE%"=="0" (
    if exist "%removerDir%\Defender Remover.exe" (
        start /wait "" "%removerDir%\Defender Remover.exe"
    )
) else (
    echo Windows Defender removal skipped.
)

timeout /t 3 >nul
exit