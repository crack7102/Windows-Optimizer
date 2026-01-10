::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul


:: ===============================
::       DISINSTALLA APP
:: ===============================

cls
echo ============================================
echo        RIMOZIONE APP PREINSTALLATE
echo ============================================
echo.

set "removerDir=%~dp0Remover"

:: =======================================
::            WINDOWS STORE APP
:: =======================================
echo Avvio di PowerShell in finestra separata, verranno rimosse le app del Windows Store.
timeout /t 3 >nul

echo.

start /wait powershell -ExecutionPolicy Bypass -File "%removerDir%\DisinstallaApp.ps1"

timeout /t 2 >nul

:: =======================================
::            HIBIT UNINSTALLER
:: =======================================
echo Avvio di HiBit Uninstaller per rimuovere tutte le altre app, comprese quelle di sistema.
timeout /t 3 >nul

start /wait "" "%removerDir%\HiBit Uninstaller.exe" || exit /b 0
echo.

timeout /t 2 >nul

:: =======================================
::         RIMOZIONE MICROSOFT EDGE
:: =======================================
echo Avvio del programma per la rimozione di Microsoft Edge dal sistema.
echo.
timeout /t 3 >nul
chcp 437 >nul 2>&1
powershell -NoProfile -Command ^
"[void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $r = [System.Windows.Forms.MessageBox]::Show('Vuoi rimuovere Microsoft Edge?','Rimozione Edge','YesNo','Question'); if($r -eq 'Yes'){exit 0}else{exit 1}"
set "EDGE_CHOICE=%errorlevel%"
if "%EDGE_CHOICE%"=="" set "EDGE_CHOICE=1"
chcp 65001 >nul 2>&1

if "%EDGE_CHOICE%"=="0" (
    :: Chiudere tutti i processi Edge
    taskkill /IM msedge.exe /F /T >nul 2>&1
    taskkill /IM msedgewebview2.exe /F /T >nul 2>&1
    taskkill /IM MicrosoftEdgeUpdate.exe /F /T >nul 2>&1
    taskkill /IM edgeupdate.exe /F /T >nul 2>&1
    taskkill /IM setup.exe /F /T >nul 2>&1

    :: Disinstallatore aggiuntivo (se presente)
    if exist "%removerDir%\Edge Remover.exe" (
        start /wait "" "%removerDir%\Edge Remover.exe"
    )
) else (
    echo Rimozione di Microsoft Edge saltata.
)
echo.
timeout /t 2 >nul

:: =======================================
::       RIMOZIONE WINDOWS DEFENDER
:: =======================================
echo Avvio del programma per la rimozione di Windows Defender dal sistema.
echo.
timeout /t 3 >nul
chcp 437 >nul 2>&1
powershell -NoProfile -Command ^
"[void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $r = [System.Windows.Forms.MessageBox]::Show('Vuoi rimuovere completamente Windows Defender?','Rimozione Windows Defender','YesNo','Question'); if($r -eq 'Yes'){exit 0}else{exit 1}"
set "DEFENDER_CHOICE=%errorlevel%"
if "%DEFENDER_CHOICE%"=="" set "DEFENDER_CHOICE=1"
chcp 65001 >nul 2>&1

if "%DEFENDER_CHOICE%"=="0" (
    if exist "%removerDir%\Defender Remover.exe" (
        start /wait "" "%removerDir%\Defender Remover.exe"
    )
) else (
    echo Rimozione di Windows Defender saltata.
)

 timeout /t 3 >nul
 
:: Torna al menu principale dopo la chiusura di PowerShell
exit