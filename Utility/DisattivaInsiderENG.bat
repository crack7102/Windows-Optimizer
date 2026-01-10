::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul

:: ======================================
::       DISABLE WINDOWS INSIDER
:: ======================================
echo Disabling Windows Insider Program...

:: Close Settings to avoid lock
taskkill /f /im "Settings.exe" >nul 2>&1

:: Removing Windows Insider Keys and Files
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f >nul 2>&1
schtasks /Delete /TN "\Microsoft\Windows\WindowsUpdate\FlightMetadata" /F >nul 2>&1
schtasks /Delete /TN "\Microsoft\Windows\Flighting\FeatureConfig\ReconcileFeatures" /F >nul 2>&1
schtasks /Delete /TN "\Microsoft\Windows\Flighting\OneSettings\RefreshCache" /F >nul 2>&1
rmdir /s /q "%ProgramData%\Microsoft\WindowsSelfHost" >nul 2>&1
rmdir /s /q "%LOCALAPPDATA%\Microsoft\WindowsSelfHost" >nul 2>&1

:: Retail Configuration Restore
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /v "BranchName" /t REG_SZ /d "Retail" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /v "ContentType" /t REG_SZ /d "Mainline" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /v "Ring" /t REG_SZ /d "Retail" /f >nul 2>&1

:: Hide Insider page in settings
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /t REG_DWORD /d 1 /f >nul 2>&1

:: Disable Insider trials
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowExperimentation" /v "value" /t REG_DWORD /d 0 /f >nul 2>&1
timeout /t 3 >nul
echo Windows Insider Program completely removed.
timeout /t 2 >nul
exit