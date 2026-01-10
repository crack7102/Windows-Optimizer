::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul

:: ===============================
::         SERVICE MANAGEMENT
:: ===============================

cls
echo =================================================
echo             WINDOWS SERVICE MANAGEMENT
echo =================================================
echo [1] Disable unnecessary services
echo [2] Re-enable default services
echo ----------------------------------------------------
set "SERVIZI_LIST=AdobeARMservice vmicguestinterface vmicvss vmicshutdown vmicheartbeat vmicvmsession vmickvpexchange vmictimesync vmicrdv RasAuto workfolderssvc RasMan DusmSvc UmRdpService LanmanServer TermService SensorDataService RetailDemo ScDeviceEnum RmSvc SensrSvc AJRouter PhoneSvc SCardSvr TapiSrv LanmanWorkstation Fax MapsBroker SensorService BcastDVRUserService_76dfd DiagTrack lfsvc PcaSvc SCPolicySvc seclogon SmsRouter wisvc XblAuthManager XblGameSave XboxNetApiSvc XboxGipSvc SessionEnv WpcMonSvc SEMgrSvc MicrosoftEdgeElevationService edgeupdate edgeupdatem CryptSvc BDESVC StiSvc CscService WdiSystemHost HvHost WbioSrvc WMPNetworkSvc SysMain wcncsvc wercplsupport"
set /p serv=Choice: 
if "%serv%"=="1" call :SERVIZI_AUTOMATICO & echo All unnecessary services have been disabled! & timeout /t 2 >nul & exit
if "%serv%"=="2" (
    for %%S in (%SERVIZI_LIST%) do (
        sc config %%~S start=auto >nul 2>&1
        sc start %%S >nul 2>&1
    )
    echo.
    echo All services have been successfully restored!
    timeout /t 2 >nul
    exit
)
echo Invalid choice!.
timeout /t 2 >nul
exit

:SERVIZI_AUTOMATICO
echo.
echo Disabling unnecessary services...
for %%S in (%SERVIZI_LIST%) do (
    sc config %%~S start=disabled >nul 2>&1
    sc stop %%S >nul 2>&1
)
exit /b
