::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul

:: ===============================
::         GESTIÓN DE SERVICIOS
:: ===============================

cls
echo =================================================
echo             GESTIÓN DE SERVICIOS DE WINDOWS
echo =================================================
echo [1] Desactivar servicios innecesarios
echo [2] Volver a activar servicios predeterminados
echo ----------------------------------------------------
set "SERVIZI_LIST=AdobeARMservice vmicguestinterface vmicvss vmicshutdown vmicheartbeat vmicvmsession vmickvpexchange vmictimesync vmicrdv RasAuto workfolderssvc RasMan DusmSvc UmRdpService LanmanServer TermService SensorDataService RetailDemo ScDeviceEnum RmSvc SensrSvc AJRouter PhoneSvc SCardSvr TapiSrv LanmanWorkstation Fax MapsBroker SensorService BcastDVRUserService_76dfd DiagTrack lfsvc PcaSvc SCPolicySvc seclogon SmsRouter wisvc XblAuthManager XblGameSave XboxNetApiSvc XboxGipSvc SessionEnv WpcMonSvc SEMgrSvc MicrosoftEdgeElevationService edgeupdate edgeupdatem CryptSvc BDESVC StiSvc CscService WdiSystemHost HvHost WbioSrvc WMPNetworkSvc SysMain wcncsvc wercplsupport"
set /p serv=Elección: 
if "%serv%"=="1" call :SERVIZI_AUTOMATICO & echo ¡Se han desactivado todos los servicios innecesarios! & timeout /t 2 >nul & exit
if "%serv%"=="2" (
    for %%S in (%SERVIZI_LIST%) do (
        sc config %%~S start=auto >nul 2>&1
        sc start %%S >nul 2>&1
    )
    echo.
    echo ¡Todos los servicios se han restablecido correctamente!
    timeout /t 2 >nul
    exit
)
echo ¡Elección no válida!
timeout /t 2 >nul
exit

:SERVIZI_AUTOMATICO
echo.
echo Desactivando servicios innecesarios...
for %%S in (%SERVIZI_LIST%) do (
    sc config %%~S start=disabled >nul 2>&1
    sc stop %%S >nul 2>&1
)
exit /b
