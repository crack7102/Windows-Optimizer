::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul

:: ===============================
::     CLEAN TEMPORARY FILES
:: ===============================

cls
echo ================================================
echo            CLEAN TEMPORARY FILES
echo ================================================
echo [1/5] Cleaning system temporary files...
if exist "%TEMP%\*" del /f /s /q "%TEMP%\*" >nul 2>&1
if exist "C:\Users\%USERNAME%\AppData\Local\Temp\*" del /f /s /q "C:\Users\%USERNAME%\AppData\Local\Temp\*" >nul 2>&1
timeout /t 1 >nul

echo [2/5] Deep cleaning and clearing Prefetch folder...
set "SYSTEM_TEMP_LIST=C:\Windows\Temp\ C:\Windows\Prefetch\ %LOCALAPPDATA%\Packages\Temp %LOCALAPPDATA%\Microsoft\Windows\INetCache\ %LOCALAPPDATA%\Microsoft\Windows\WebCache\ C:\Windows\ServiceProfiles\LocalService\AppData\Local\Temp\ C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Temp\ %LOCALAPPDATA%\Microsoft\Windows\Explorer\"
for %%D in (%SYSTEM_TEMP_LIST%) do (
    if exist "%%D*" del /f /s /q "%%D*" >nul 2>&1
)
timeout /t 1 >nul

echo [3/5] Cleaning Windows event logs...
for /F "tokens=*" %%G in ('wevtutil el') do wevtutil cl "%%G" >nul 2>&1
timeout /t 1 >nul

echo [4/5] Cleaning Windows Update cache...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
if exist "C:\Windows\SoftwareDistribution\Download\*" del /s /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
timeout /t 1 >nul

echo [5/5] Final Windows cleanup...
ipconfig /flushdns >nul
cleanmgr /sagerun:1 >nul 2>&1
timeout /t 1 >nul

echo Cleaning completed successfully!
timeout /t 2 >nul
exit