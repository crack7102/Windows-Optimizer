::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul

:: ===============================
::       DESINSTALAR APPS
:: ===============================

cls
echo ============================================
echo        ELIMINACIÓN DE APPS PREINSTALADAS
echo ============================================
echo.

set "removerDir=%~dp0Remover"

:: =======================================
::            WINDOWS STORE APP
:: =======================================
echo Iniciando PowerShell en ventana separada para remover apps del Windows Store.
timeout /t 3 >nul

echo. 

start /wait powershell -ExecutionPolicy Bypass -File "%removerDir%\DesinstalaApp.ps1"

timeout /t 2 >nul

:: =======================================
::            HIBIT UNINSTALLER
:: =======================================
echo Iniciando HiBit Uninstaller para remover otras apps, incluidas las de sistema.
timeout /t 3 >nul

start /wait "" "%removerDir%\HiBit Uninstaller.exe" || exit /b 0
echo.

timeout /t 2 >nul

:: =======================================
::      ELIMINACIÓN DE MICROSOFT EDGE
:: =======================================
echo Iniciando programa para remover Microsoft Edge.
echo.
timeout /t 3 >nul
chcp 437 >nul 2>&1
powershell -NoProfile -Command ^
"[void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $r = [System.Windows.Forms.MessageBox]::Show('¿Deseas remover Microsoft Edge?','Remover Edge','YesNo','Question'); if($r -eq 'Yes'){exit 0}else{exit 1}"
set "EDGE_CHOICE=%errorlevel%"
if "%EDGE_CHOICE%"=="" set "EDGE_CHOICE=1"
chcp 65001 >nul 2>&1

if "%EDGE_CHOICE%"=="0" (
    :: Cerrar todos los procesos Edge
    taskkill /IM msedge.exe /F /T >nul 2>&1
    taskkill /IM msedgewebview2.exe /F /T >nul 2>&1
    taskkill /IM MicrosoftEdgeUpdate.exe /F /T >nul 2>&1
    taskkill /IM edgeupdate.exe /F /T >nul 2>&1
    taskkill /IM setup.exe /F /T >nul 2>&1
	
    :: Desinstalador adicional (si lo hay)
    if exist "%removerDir%\Edge Remover.exe" (
        start /wait "" "%removerDir%\Edge Remover.exe"
    )
) else (
    echo Eliminación de Microsoft Edge omitida.
)
echo.
timeout /t 2 >nul

:: =======================================
::     ELIMINACIÓN DE WINDOWS DEFENDER
:: =======================================
echo Iniciando programa para remover Windows Defender.
echo.
timeout /t 3 >nul
chcp 437 >nul 2>&1
powershell -NoProfile -Command ^
"[void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $r = [System.Windows.Forms.MessageBox]::Show('¿Deseas eliminar completamente Windows Defender?','Eliminar Windows Defender','YesNo','Question'); if($r -eq 'Yes'){exit 0}else{exit 1}"
set "DEFENDER_CHOICE=%errorlevel%"
if "%DEFENDER_CHOICE%"=="" set "DEFENDER_CHOICE=1"
chcp 65001 >nul 2>&1

if "%DEFENDER_CHOICE%"=="0" (
    if exist "%removerDir%\Defender Remover.exe" (
        start /wait "" "%removerDir%\Defender Remover.exe"
    )
) else (
    echo Eliminación de Windows Defender omitida.
)

 timeout /t 3 >nul

:: Volver al menú principal después de cerrar PowerShell
exit