@echo off
title Software per l'ottimizzazione PC creato da Riccardo Ferrini
color F0
chcp 65001 >nul

:: ===============================
::     SCHERMATA DI BENVENUTO
:: ===============================
cls
echo ====================================================
echo                 OTTIMIZZAZIONE PC
echo ====================================================
echo.
echo Questo programma serve a:
echo  - Rimuovere file temporanei, cache e dati non necessari per velocizzare il PC;
echo  - Migliorare le prestazioni di Windows;
echo  - Gestire e disattivare servizi di Windows inutili;
echo  - Fornire programmi aggiuntivi nella sezione Extra.
echo.
echo Premi un tasto per aprire il menu...
pause >nul

:: ==================================
::   CREAZIONE PUNTO DI RIPRISTINO
:: ==================================
cls
echo ====================================================
echo        CREAZIONE PUNTO DI RIPRISTINO DI SISTEMA
echo ====================================================
echo.
echo Vuoi creare un punto di ripristino completo prima di procedere?
echo (consigliato in caso di modifiche al sistema)
echo.
set /p risposta=Creare punto di ripristino? (Y/N): 

if /I "%risposta%"=="Y" (
    echo.
    echo Creazione in corso del punto di ripristino...
    chcp 437 >nul 2>&1
    powershell -Command "Checkpoint-Computer -Description 'Punto di Ripristino Pre Ottimizzazione'"
    powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Punto di ripristino completato con successo, premere OK per continuare','Proprietà del sistema',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)}"
    chcp 65001 >nul 2>&1
) else (
    echo.
    echo Creazione punto di ripristino saltata.
    timeout /t 2 >nul
)
cls
goto :MENU

:: ===============================
::         MENÙ PRINCIPALE
:: ===============================
:MENU
cls
echo ====================================================
echo         OTTIMIZZAZIONE PC - MENÙ PRINCIPALE
echo ====================================================
echo.
echo  [0] Ottimizza il PC automaticamente
echo  [1] Pulizia file temporanei
echo  [2] Ottimizzazione disco e sistema
echo  [3] Installa Microsoft Visual C++ Redistributable e DirectX 11
echo  [4] Tweak - Ottimizzazioni Windows
echo  [5] Gestione servizi Windows
echo  [6] Aggiornamento app
echo  [7] Disinstalla App
echo  [8] Installatore Multi App
echo  [9] Contiene strumenti extra
echo  [10] Esci
echo.
set /p scelta=Seleziona un'opzione: 

for /f "delims=0123456789" %%a in ("%scelta%") do set scelta=invalid
if "%scelta%"=="invalid" goto INVALID
if "%scelta%"=="0" goto AUTO
if "%scelta%"=="1" goto PULIZIA
if "%scelta%"=="2" goto OTTIMIZZA
if "%scelta%"=="3" goto REDIST
if "%scelta%"=="4" goto TWEAK
if "%scelta%"=="5" goto SERVIZI
if "%scelta%"=="6" goto AGGIORNAMENTO_APP
if "%scelta%"=="7" goto DISINSTALLA_APP
if "%scelta%"=="8" goto MULTIAPP
if "%scelta%"=="9" goto EXTRA
if "%scelta%"=="10" exit
:INVALID
echo.
echo Scelta non valida!. Riprova.
pause >nul
goto MENU

:: ===============================
::       AGGIORNAMENTO APP
:: ===============================
:AGGIORNAMENTO_APP
cls
echo =================================================
echo                AGGIORNAMENTO APP
echo =================================================
echo.
echo Aggiornamento automatico di tutte le app tramite winget in finestra separata...
start powershell -NoExit -Command "winget update; winget upgrade --all --accept-source-agreements --accept-package-agreements; exit"
echo.
echo Aggiornamento avviato in finestra separata.
if "%AUTO_MODE%"=="1" exit /b
pause
goto MENU

:: ===============================
::     PULIZIA FILE TEMPORANEI
:: ===============================
:PULIZIA
cls
echo ================================================
echo            PULIZIA FILE TEMPORANEI
echo ================================================
echo [1/5] Pulizia file temporanei di sistema...
if exist "%TEMP%\*" del /f /s /q "%TEMP%\*" >nul 2>&1
if exist "C:\Users\%USERNAME%\AppData\Local\Temp\*" del /f /s /q "C:\Users\%USERNAME%\AppData\Local\Temp\*" >nul 2>&1
timeout /t 1 >nul

echo [2/5] Pulizia approfondita e svuotamento della cartella Prefetch...
set "SYSTEM_TEMP_LIST=C:\Windows\Temp\ C:\Windows\Prefetch\ %LOCALAPPDATA%\Packages\Temp %LOCALAPPDATA%\Microsoft\Windows\INetCache\ %LOCALAPPDATA%\Microsoft\Windows\WebCache\ C:\Windows\ServiceProfiles\LocalService\AppData\Local\Temp\ C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Temp\ %LOCALAPPDATA%\Microsoft\Windows\Explorer\"
for %%D in (%SYSTEM_TEMP_LIST%) do (
    if exist "%%D*" del /f /s /q "%%D*" >nul 2>&1
)
timeout /t 1 >nul

echo [3/5] Pulizia log eventi di Windows...
for /F "tokens=*" %%G in ('wevtutil el') do wevtutil cl "%%G" >nul 2>&1
timeout /t 1 >nul

echo [4/5] Pulizia cache di Windows Update...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
if exist "C:\Windows\SoftwareDistribution\Download\*" del /s /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
timeout /t 1 >nul

echo [5/5] Pulizia finale di Windows...
ipconfig /flushdns >nul
cleanmgr /sagerun:1 >nul 2>&1
timeout /t 1 >nul

echo Pulizia completata con successo!
if "%AUTO_MODE%"=="1" exit /b
pause
goto MENU

:: ===================================
::   OTTIMIZZAZIONE DISCO E SISTEMA
:: ===================================
:OTTIMIZZA
cls
echo ==================================================
echo         OTTIMIZZAZIONE DISCO E SISTEMA
echo ==================================================
echo.
echo Avvio del controllo dell'integrità immagine di sistema...
echo (Questo processo può richiedere diversi minuti)
echo ----------------------------------------------------
timeout /t 2 >nul

echo Esecuzione: DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /CheckHealth
echo ----------------------------------------------------
echo Esecuzione: DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /ScanHealth
echo ----------------------------------------------------
echo Esecuzione: DISM /Online /Cleanup-Image /RestoreHealth
DISM /Online /Cleanup-Image /RestoreHealth
echo ----------------------------------------------------

echo Verifica file di sistema in corso...
sfc /scannow
echo ----------------------------------------------------

echo Rilevamento del tipo di unità di archiviazione (SSD/HDD)...
where wmic >nul 2>&1
if %errorlevel% neq 0 (
    echo WMIC non trovato. Impossibile determinare il tipo di unita'.
    goto :EOF
)

wmic diskdrive get model, mediatype | find /I "SSD" >nul 2>&1
if %errorlevel%==0 (
    echo Rilevato SSD - ottimizzazione in corso...
    defrag C: /L /O
) else (
    echo Rilevato HDD - deframmentazione e ottimizzazione in corso...
    defrag C: /O
)
echo.
echo Ottimizzazione completata con successo!
if "%AUTO_MODE%"=="1" exit /b
pause
goto MENU

:: ==========================================
::     INSTALLAZIONE REDIST & DIRECTX 11
:: ==========================================
:REDIST
cls

:: Percorso della cartella Utility
set "basePath=%~dp0Utility"

:: Avvio installazione pacchetto Visual C++
echo Installazione del pacchetto Microsoft Visual C++ Redistributable in corso...
start "" /wait "%basePath%\Microsoft Visual C++ Redist Package.exe"
echo.

:: Avvio installazione DirectX 11
echo Installazione dei componenti DirectX 11 in corso...
start "" /wait "%basePath%\DirectX End-User Runtimes (June 2010).exe"
echo.

if "%AUTO_MODE%"=="1" exit /b

echo Installazione completata con successo.
timeout /t 3 >nul
goto MENU

:: ===============================
::              TWEAK
:: ===============================
:TWEAK
cls
echo ====================================================
echo                     MENU TWEAK
echo ====================================================
echo.
echo  [1] Modifica l'aspetto e le prestazioni di Windows
echo  [2] Opzioni risparmio energia - Prestazioni elevate
echo  [3] Sistema audio
echo  [4] Attiva la Modalità Gioco
echo  [5] Disattiva app in background
echo  [6] Disattiva trasparenza
echo  [7] Fix CPU e GPU
echo  [8] Disattiva Windows Insider
echo  [9] Torna al menu principale
echo ----------------------------------------------------
set /p tweak_scelta=Seleziona un'opzione: 

if "%tweak_scelta%"=="1" start "" SystemPropertiesPerformance.exe & goto TWEAK
if "%tweak_scelta%"=="2" (
    powercfg -setactive SCHEME_MIN
    echo Prestazioni elevate applicate!
    timeout /t 1 >nul
    goto TWEAK
)
if "%tweak_scelta%"=="3" start "" mmsys.cpl & goto TWEAK
if "%tweak_scelta%"=="4" (
    call :MODALITA_GIOCO
    echo Modalità Gioco attivata!
    timeout /t 1 >nul
    goto TWEAK
)
if "%tweak_scelta%"=="5" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul 2>&1
    echo App in background disattivate!
    timeout /t 1 >nul
    goto TWEAK
)
if "%tweak_scelta%"=="6" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul 2>&1
    echo Trasparenza disattivata!
    timeout /t 1 >nul
    goto TWEAK
)
if "%tweak_scelta%"=="7" goto FIX_CPU_GPU
if "%tweak_scelta%"=="8" call :DISATTIVA_INSIDER
if "%tweak_scelta%"=="9" goto MENU
echo Scelta non valida!.
pause
goto TWEAK

:: ======================================
::       DISATTIVA WINDOWS INSIDER
:: ======================================
:DISATTIVA_INSIDER

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
if "%AUTO_MODE%"=="1" (
    exit /b
) else (
    timeout /t 2 >nul
    goto TWEAK
)

:: ===============================
::          MODALITA GIOCO
:: ===============================
:MODALITA_GIOCO
reg add "HKCU\Control Panel\Desktop" /v AutoEndTasks /t REG_SZ /d 1 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d 1000 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 8 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v WaitToKillAppTimeout /t REG_SZ /d 2000 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v LowLevelHooksTimeout /t REG_SZ /d 1000 /f >nul 2>&1

:: ===============================
::           FIX CPU+GPU
:: ===============================
:FIX_CPU_GPU
cls
echo ====================================================
echo                FIX CPU+GPU
echo ====================================================

:: ===============================
:: Rilevamento CPU
:: ===============================
echo Rilevamento della tua CPU...
for /f "tokens=*" %%C in ('wmic cpu get name ^| findstr /r /v "^$"') do set "CPU_NAME=%%C"

:: ===============================
:: Blocchi comuni
:: ===============================
:: Disattivazione Core Parking e Power Throttling
set "CORE_PARKING=HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583"
reg add "%CORE_PARKING%" /v "Attributes" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes" /v "Attributes" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Throttle" /v "PerfEnablePackageIdle" /t REG_DWORD /d 0 /f >nul 2>&1

:: ===============================
:: Fix CPU
:: ===============================

:: Intel CPU
echo %CPU_NAME% | findstr /i "Intel" >nul
if %errorlevel%==0 (
    echo CPU Intel rilevata: applico i fix e imposto tutto alle massime prestazioni...

    for %%S in ("Intel Telemetry" "DSAService") do (
        sc query %%~S >nul 2>&1 && (sc stop %%~S >nul 2>&1 & sc config %%~S start=disabled >nul 2>&1)
    )

    reg add "HKLM\SOFTWARE\Intel\CPU" /v "PerformanceMode" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Intel\CPU" /v "TurboBoost" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Intel\CPU" /v "EnergyEfficient" /t REG_DWORD /d 0 /f >nul 2>&1
)

:: AMD CPU
echo %CPU_NAME% | findstr /i "AMD" >nul
if %errorlevel%==0 (
    echo CPU AMD rilevata: applico i fix e imposto tutto alle massime prestazioni...

    for %%S in ("AMD External Events Utility" "AMDRSServ") do (
        sc query %%~S >nul 2>&1 && (sc stop %%~S >nul 2>&1 & sc config %%~S start=disabled >nul 2>&1)
    )

    reg add "HKLM\SOFTWARE\AMD\CPU" /v "PerformanceMode" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\AMD\CPU" /v "PrecisionBoost" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\AMD\CPU" /v "EcoMode" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\AMD\CPU" /v "MaxFrequencyOverride" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\AMD\CPU" /v "VoltageOptimization" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\amdppm" /v "PerfBoostMode" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\amdppm" /v "PerfBias" /t REG_DWORD /d 0 /f >nul 2>&1
)

:: ===============================
:: Rilevamento GPU
:: ===============================
for /f "tokens=*" %%G in ('wmic path win32_VideoController get name ^| findstr /r /v "^$"') do set "GPU_NAME=%%G"

:: ===============================
:: Blocchi comuni GPU
:: ===============================
set "GRAPHICS_REGS=HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
reg add "%GRAPHICS_REGS%" /v "FlipQueueSize" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%GRAPHICS_REGS%" /v "TdrDelay" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "%GRAPHICS_REGS%" /v "TdrLevel" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%GRAPHICS_REGS%" /v "PowerEfficiency" /t REG_DWORD /d 0 /f >nul 2>&1

:: ===============================
:: FIX GPU
:: ===============================

:: NVIDIA GPU
echo %GPU_NAME% | findstr /i "NVIDIA" >nul
if %errorlevel%==0 (
    echo GPU NVIDIA rilevata: applico i fix e imposto tutto alle massime prestazioni...

    for %%S in ("NvTelemetryContainer" "NvContainerLocalSystem" "NvContainerNetworkService") do (
        sc query %%~S >nul 2>&1 && (sc stop %%~S >nul 2>&1 & sc config %%~S start=disabled >nul 2>&1)
    )

    reg add "HKCU\Software\NVIDIA Corporation\Global\NvTweak" /v "TripleBuffering" /t REG_DWORD /d 1 /f >nul 2>&1
    set "NVTweak=HKLM\SOFTWARE\NVIDIA Corporation\Global\NVTweak"
    reg add "%NVTweak%" /f >nul 2>&1
    reg add "%NVTweak%" /v ThreadedOptimization /t REG_DWORD /d 0 /f >nul 2>&1

    set "PowerMizer=HKLM\SOFTWARE\NVIDIA Corporation\Global\PowerMizer"
    reg add "%PowerMizer%" /f >nul 2>&1
    reg add "%PowerMizer%" /v PerfLevelSrc /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "%PowerMizer%" /v PowerMizerEnable /t REG_DWORD /d 1 /f >nul 2>&1

    set "NVDriver=HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters"
    reg add "%NVDriver%" /f >nul 2>&1
    reg add "%NVDriver%" /v DmaRemappingCompatible /t REG_DWORD /d 0 /f >nul 2>&1
    for %%v in (LogWarningEntries LogPagingEntries LogEventEntries LogErrorEntries) do (
        reg add "%NVDriver%" /v %%v /t REG_DWORD /d 0 /f >nul 2>&1
    )
)

:: AMD GPU
echo %GPU_NAME% | findstr /i "AMD" >nul
if %errorlevel%==0 (
    echo GPU AMD rilevata: applico i fix e imposto tutto alle massime prestazioni...

    for %%S in ("AMD External Events Utility" "AMDRSServ") do (
        sc query %%~S >nul 2>&1 && (sc stop %%~S >nul 2>&1 & sc config %%~S start=disabled >nul 2>&1)
    )

    reg add "HKCU\Software\AMD\CN" /v "TripleBuffering" /t REG_DWORD /d 1 /f >nul 2>&1
    set "AMD_UMD=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD"
    reg add "%AMD_UMD%" /f >nul 2>&1
    reg add "%AMD_UMD%" /v "ShaderCache" /t REG_BINARY /d 32 /f >nul 2>&1
    reg add "%AMD_UMD%" /v "UltraLowPowerState" /t REG_DWORD /d 0 /f >nul 2>&1

    reg add "HKLM\SOFTWARE\AMD\CN" /v "OverlayEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\AMD\CN" /v "AntiLag" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\AMD\CN" /v "FrameGenerationEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

    set "AMD_KMD=HKLM\SYSTEM\CurrentControlSet\Services\amdkmdag"
    reg add "%AMD_KMD%" /v "PP_DisableDPM" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "%AMD_KMD%" /v "EnableUlps" /t REG_DWORD /d 0 /f >nul 2>&1
)

:: Intel GPU
echo %GPU_NAME% | findstr /i "Intel" >nul
if %errorlevel%==0 (
    echo GPU Intel rilevata: applico i fix e imposto tutto alle massime prestazioni...

    reg add "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" /t REG_DWORD /d 512 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Intel\GMM" /v "PreAllocatedSystemMemory" /t REG_DWORD /d 256 /f >nul 2>&1
    reg add "HKCU\Software\Intel\IGFX" /v "DisableOverlay" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\Software\Intel\IGFX" /v "TripleBuffering" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\Software\Intel\IGFX" /v "LowLatencyMode" /t REG_DWORD /d 1 /f >nul 2>&1
)

echo ====================================================
echo Ottimizzazione completata con successo!
pause
goto TWEAK

:: ===============================
::         GESTIONE SERVIZI
:: ===============================
:SERVIZI
cls
echo =================================================
echo             GESTIONE SERVIZI WINDOWS
echo =================================================
echo [1] Disattiva servizi inutili
echo [2] Riattiva servizi predefiniti
echo [3] Torna al menu principale
echo ----------------------------------------------------
set "SERVIZI_LIST=AdobeARMservice vmicguestinterface vmicvss vmicshutdown vmicheartbeat vmicvmsession vmickvpexchange vmictimesync vmicrdv RasAuto workfolderssvc RasMan DusmSvc UmRdpService LanmanServer TermService SensorDataService RetailDemo ScDeviceEnum RmSvc SensrSvc AJRouter PhoneSvc SCardSvr TapiSrv LanmanWorkstation Fax MapsBroker SensorService BcastDVRUserService_76dfd DiagTrack lfsvc PcaSvc SCPolicySvc seclogon SmsRouter wisvc XblAuthManager XblGameSave XboxNetApiSvc XboxGipSvc SessionEnv WpcMonSvc SEMgrSvc MicrosoftEdgeElevationService edgeupdate edgeupdatem CryptSvc BDESVC StiSvc CscService WdiSystemHost HvHost WbioSrvc WMPNetworkSvc SysMain wcncsvc wercplsupport"
set /p serv=Scelta: 
if "%serv%"=="1" call :SERVIZI_AUTOMATICO & echo Tutti i servizi inutili sono stati disattivati! & pause & goto SERVIZI
if "%serv%"=="2" (
    for %%S in (%SERVIZI_LIST%) do (
        sc config %%~S start=auto >nul 2>&1
        sc start %%S >nul 2>&1
    )
    echo Tutti i servizi sono stati ripristinati con successo!
    pause
    goto SERVIZI
)
if "%serv%"=="3" goto MENU
echo Scelta non valida!.
pause
goto SERVIZI

:SERVIZI_AUTOMATICO
for %%S in (%SERVIZI_LIST%) do (
    sc config %%~S start=disabled >nul 2>&1
    sc stop %%S >nul 2>&1
)
exit /b

:: ===============================
::         SEZIONE EXTRA
:: ===============================
:EXTRA
cls
echo ====================================================
echo               SEZIONE EXTRA - PROGRAMMI
echo ====================================================
setlocal enabledelayedexpansion
set i=0
set "ExtraDir=%~dp0Extra"
if not exist "%ExtraDir%" (
    echo La cartella "Extra" non esiste.
    pause
    endlocal
    goto MENU
)

rem Carica file EXE, BAT, CMD e PS1
for %%F in ("%ExtraDir%\*.exe" "%ExtraDir%\*.bat" "%ExtraDir%\*.cmd" "%ExtraDir%\*.ps1") do (
    set /a i+=1
    set "Programmi!i!=%%~fF"
    echo  [!i!] %%~nxF
)

if !i! EQU 0 (
    echo Nessun programma è trovato nella cartella Extra.
    pause
    endlocal
    goto MENU
)

set /a maxnum=!i!+1
echo  [!maxnum!] Torna al menu principale
echo ----------------------------------------------------
set /p scelta_extra=Seleziona il programma da avviare: 

if "!scelta_extra!"=="" endlocal & goto EXTRA
if !scelta_extra! LSS 1 endlocal & goto EXTRA
if !scelta_extra! GTR !maxnum! endlocal & goto EXTRA
if "!scelta_extra!"=="!maxnum!" endlocal & goto MENU

rem Ottieni percorso file corretto usando call set
call set "prog=%%Programmi%scelta_extra%%%"
if exist "!prog!" (
    rem Avvio come amministratore
    if /i "!prog:~-3!"=="ps1" (
        powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"!prog!\"' -Verb RunAs"
    ) else (
        powershell -Command "Start-Process '!prog!' -Verb RunAs"
    )
) else (
    echo File non trovato: !prog!
    pause
)

endlocal
goto EXTRA

:: ===============================
::       DISINSTALLA APP
:: ===============================
:DISINSTALLA_APP
cls
echo ============================================
echo        RIMOZIONE APP PREINSTALLATE
echo ============================================
echo.

set "utilityDir=%~dp0Utility"

:: =======================================
::            WINDOWS STORE APP
:: =======================================
echo Avvio di PowerShell in finestra separata, verranno rimosse le app del Windows Store.
timeout /t 3 >nul

echo.

start /wait powershell -ExecutionPolicy Bypass -File "%utilityDir%\DisinstallaApp.ps1"

timeout /t 2 >nul

:: =======================================
::            HIBIT UNINSTALLER
:: =======================================
echo Avvio di HiBit Uninstaller per rimuovere tutte le altre app, comprese quelle di sistema.
timeout /t 3 >nul

start /wait "" "%utilityDir%\HiBit Uninstaller.exe" || exit /b 0
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
    if exist "%utilityDir%\Edge Remover.exe" (
        start /wait "" "%utilityDir%\Edge Remover.exe"
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
    if exist "%utilityDir%\Defender Remover.exe" (
        start /wait "" "%utilityDir%\Defender Remover.exe"
    )
) else (
    echo Rimozione di Windows Defender saltata.
)

 timeout /t 3 >nul
 
:: Torna al menu principale dopo la chiusura di PowerShell
goto MENU

:: ===================================
::       INSTALLATORE MULTI APP      
:: ===================================
:MULTIAPP
cls
echo ====================================================
echo               INSTALLATORE MULTI APP
echo ====================================================
echo.

set "utilityDir=%~dp0Utility"

if not exist "%utilityDir%\MultiApp.ps1" (
    echo Errore: il file MultiApp.ps1 non trovato nella cartella Utility.
    echo Inseriscilo nella cartella Utility nascosta e riprova.
    pause
    goto MENU
)

:: Messaggio informativo
echo Apertura di PowerShell in finestra separata. Attendere la chiusura per tornare al menu...
echo.

:: Avvio PowerShell esterno e attesa chiusura
start /wait powershell -ExecutionPolicy Bypass -File "%utilityDir%\MultiApp.ps1"

:: Torna al menu principale dopo la chiusura di PowerShell
goto MENU

:: ===============================
::       MODALITÀ AUTOMATICA
:: ===============================
:AUTO
set "AUTO_MODE=1"

call :PULIZIA
call :OTTIMIZZA
call :REDIST
call :SERVIZI_AUTOMATICO
call :MODALITA_GIOCO
call :DISATTIVA_INSIDER
call :AGGIORNAMENTO_APP
call :FIX_CPU_GPU

:: Tweak principali automatici
powercfg -setactive SCHEME_MIN >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul 2>&1

cls
echo ====================================================
echo Ottimizzazione automatica completata con successo!
echo ====================================================
pause
set "AUTO_MODE="
goto MENU