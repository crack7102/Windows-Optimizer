::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul

:: ===================================
::   OPTIMIZACIÓN DE DISCO Y SISTEMA
:: ===================================

cls
echo ==================================================
echo         OPTIMIZACIÓN DE DISCO Y SISTEMA
echo ==================================================
echo.
echo Comprobando la integridad de la imagen del sistema...
echo (Este proceso puede tardar varios minutos)
echo ----------------------------------------------------
timeout /t 2 >nul

echo Ejecutando: DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /CheckHealth
echo ----------------------------------------------------
echo Ejecutando: DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /ScanHealth
echo ----------------------------------------------------
echo Ejecutando: DISM /Online /Cleanup-Image /RestoreHealth
DISM /Online /Cleanup-Image /RestoreHealth
echo ----------------------------------------------------

echo Verificando archivos de sistema...
sfc /scannow
echo ----------------------------------------------------

echo Detectando tipo de unidad de almacenamiento (SSD/HDD)...
where wmic >nul 2>&1
if %errorlevel% neq 0 (
    echo WMIC no encontrado. Imposible determinar el tipo de unidad.
    goto :EOF
)

wmic diskdrive get model, mediatype | find /I "SSD" >nul 2>&1
if %errorlevel%==0 (
    echo SSD detectado - optimizando...
    defrag C: /L /O
) else (
    echo HDD detectado - desfragmentando y optimizando...
    defrag C: /O
)
echo.
echo ¡Optimización completada con éxito!
timeout /t 2 >nul
exit