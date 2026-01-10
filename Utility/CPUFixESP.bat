::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul

:: ===============================
::       Optimización CPU+GPU
:: ===============================
cls
echo ====================================================
echo               Optimización CPU+GPU
echo ====================================================

:: ===============================
:: Detección CPU
:: ===============================
echo Detectando tu CPU...
for /f "tokens=*" %%C in ('wmic cpu get name ^| findstr /r /v "^$"') do set "CPU_NAME=%%C"

:: ===============================
:: Bloques comunes CPU
:: ===============================
:: Desactivar Core Parking y Power Throttling
set "CORE_PARKING=HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583"
reg add "%CORE_PARKING%" /v "Attributes" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes" /v "Attributes" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Throttle" /v "PerfEnablePackageIdle" /t REG_DWORD /d 0 /f >nul 2>&1

:: ===============================
:: Fix CPU
:: ===============================

:: CPU Intel
echo %CPU_NAME% | findstr /i "Intel" >nul
if %errorlevel%==0 (
    echo CPU Intel detectada: aplicando fixes y configurando máximo rendimiento...

    for %%S in ("Intel Telemetry" "DSAService") do (
        sc query %%~S >nul 2>&1 && (sc stop %%~S >nul 2>&1 & sc config %%~S start=disabled >nul 2>&1)
    )

    reg add "HKLM\SOFTWARE\Intel\CPU" /v "PerformanceMode" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Intel\CPU" /v "TurboBoost" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Intel\CPU" /v "EnergyEfficient" /t REG_DWORD /d 0 /f >nul 2>&1
)

:: CPU AMD
echo %CPU_NAME% | findstr /i "AMD" >nul
if %errorlevel%==0 (
    echo CPU AMD detectada: aplicando fixes y configurando máximo rendimiento...

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
:: Detección GPU
:: ===============================
for /f "tokens=*" %%G in ('wmic path win32_VideoController get name ^| findstr /r /v "^$"') do set "GPU_NAME=%%G"

:: ===============================
:: Bloques comunes GPU
:: ===============================
set "GRAPHICS_REGS=HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
reg add "%GRAPHICS_REGS%" /v "FlipQueueSize" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%GRAPHICS_REGS%" /v "TdrDelay" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "%GRAPHICS_REGS%" /v "TdrLevel" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%GRAPHICS_REGS%" /v "PowerEfficiency" /t REG_DWORD /d 0 /f >nul 2>&1

:: ===============================
:: FIX GPU (NVIDIA/AMD/Intel)
:: ===============================
:: NVIDIA GPU
echo %GPU_NAME% | findstr /i "NVIDIA" >nul
if %errorlevel%==0 (
    echo GPU NVIDIA detectada: aplicando fixes y máximo rendimiento...

    for %%S in ("NvTelemetryContainer" "NvContainerLocalSystem" "NvContainerNetworkService") do (
        sc query %%~S >nul 2>&1 && (sc stop %%~S >nul 2>&1 & sc config %%~S start=disabled >nul 2>&1)
    )

    reg add "HKCU\Software\NVIDIA Corporation\Global\NvTweak" /v "TripleBuffering" /t REG_DWORD /d 1 /f >nul 2>&1
)

:: AMD GPU
echo %GPU_NAME% | findstr /i "AMD" >nul
if %errorlevel%==0 (
    echo GPU AMD detectada: aplicando fixes y máximo rendimiento...
)

:: Intel GPU
echo %GPU_NAME% | findstr /i "Intel" >nul
if %errorlevel%==0 (
    echo GPU Intel detectada: aplicando fixes y máximo rendimiento...
)

echo ====================================================
echo ¡Optimización completada con éxito!

timeout /t 2 >nul
exit