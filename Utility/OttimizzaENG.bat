::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul

:: ===================================
::   DISK AND SYSTEM OPTIMIZATION
:: ===================================

cls
echo ==================================================
echo         DISK AND SYSTEM OPTIMIZATION
echo ==================================================
echo.
echo Running system image health check...
echo (This process may take several minutes)
echo ----------------------------------------------------
timeout /t 2 >nul

echo Running: DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /CheckHealth
echo ----------------------------------------------------
echo Running: DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /ScanHealth
echo ----------------------------------------------------
echo Running: DISM /Online /Cleanup-Image /RestoreHealth
DISM /Online /Cleanup-Image /RestoreHealth
echo ----------------------------------------------------

echo Running system file check...
sfc /scannow
echo ----------------------------------------------------

echo Detecting storage type (SSD/HDD)...
where wmic >nul 2>&1
if %errorlevel% neq 0 (
    echo WMIC not found. Cannot determine drive type.
    goto :EOF
)

wmic diskdrive get model, mediatype | find /I "SSD" >nul 2>&1
if %errorlevel%==0 (
    echo SSD detected - optimizing...
    defrag C: /L /O
) else (
    echo HDD detected - defragmenting and optimizing...
    defrag C: /O
)
echo.
echo Optimization completed successfully!
timeout /t 2 >nul
exit