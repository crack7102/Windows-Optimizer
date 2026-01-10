::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul

:: ======================================
::       DISATTIVA WINDOWS INSIDER
:: ======================================

echo Disattivazione del programma Windows Insider in corso...

:: Chiude Impostazioni per evitare lock
taskkill /f /im "Settings.exe" >nul 2>&1

:: Rimozione chiavi e file Windows Insider
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f >nul 2>&1
schtasks /Delete /TN "\Microsoft\Windows\WindowsUpdate\FlightMetadata" /F >nul 2>&1
schtasks /Delete /TN "\Microsoft\Windows\Flighting\FeatureConfig\ReconcileFeatures" /F >nul 2>&1
schtasks /Delete /TN "\Microsoft\Windows\Flighting\OneSettings\RefreshCache" /F >nul 2>&1
rmdir /s /q "%ProgramData%\Microsoft\WindowsSelfHost" >nul 2>&1
rmdir /s /q "%LOCALAPPDATA%\Microsoft\WindowsSelfHost" >nul 2>&1

:: Ripristino configurazione Retail
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /v "BranchName" /t REG_SZ /d "Retail" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /v "ContentType" /t REG_SZ /d "Mainline" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /v "Ring" /t REG_SZ /d "Retail" /f >nul 2>&1

:: Nasconde la pagina Insider nelle impostazioni
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /t REG_DWORD /d 1 /f >nul 2>&1

:: Disattiva sperimentazioni Insider
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowExperimentation" /v "value" /t REG_DWORD /d 0 /f >nul 2>&1
timeout /t 3 >nul
echo Programma Windows Insider completamente rimosso.
timeout /t 2 >nul
exit