::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul

:: ===============================
::        CPU+GPU OPTIMIZER
:: ===============================

cls
echo ====================================================
echo                CPU+GPU OPTIMIZER
echo ====================================================

:: ===============================
:: CPU Detection
:: ===============================
echo Detecting your CPU...
for /f "tokens=*" %%C in ('wmic cpu get name ^| findstr /r /v "^$"') do set "CPU_NAME=%%C"

:: ===============================
:: Common blocks
:: ===============================
:: Disable Core Parking and Power Throttling
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
    echo Intel CPU detected: applying fixes and setting maximum performance...

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
    echo AMD CPU detected: applying fixes and setting maximum performance...

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
:: GPU Detection
:: ===============================
for /f "tokens=*" %%G in ('wmic path win32_VideoController get name ^| findstr /r /v "^$"') do set "GPU_NAME=%%G"

:: ===============================
:: Common GPU blocks
:: ===============================
set "GRAPHICS_REGS=HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
reg add "%GRAPHICS_REGS%" /v "FlipQueueSize" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%GRAPHICS_REGS%" /v "TdrDelay" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "%GRAPHICS_REGS%" /v "TdrLevel" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%GRAPHICS_REGS%" /v "PowerEfficiency" /t REG_DWORD /d 0 /f >nul 2>&1

:: ===============================
:: Fix GPU
:: ===============================

:: NVIDIA GPU
echo %GPU_NAME% | findstr /i "NVIDIA" >nul
if %errorlevel%==0 (
    echo NVIDIA GPU detected: applying fixes and setting maximum performance...

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
    echo AMD GPU detected: applying fixes and setting maximum performance...

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
    echo Intel GPU detected: applying fixes and setting maximum performance...

    reg add "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" /t REG_DWORD /d 512 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Intel\GMM" /v "PreAllocatedSystemMemory" /t REG_DWORD /d 256 /f >nul 2>&1
    reg add "HKCU\Software\Intel\IGFX" /v "DisableOverlay" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\Software\Intel\IGFX" /v "TripleBuffering" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\Software\Intel\IGFX" /v "LowLatencyMode" /t REG_DWORD /d 1 /f >nul 2>&1
)

echo ====================================================
echo Optimization completed successfully!

timeout /t 2 >nul
exit