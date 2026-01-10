::Software per l'ottimizzazione PC creato da Riccardo Ferrini
@echo off
title Windows Optimizer by Riccardo Ferrini
color F0
chcp 65001 >nul

:: ===================================
::   OTTIMIZZAZIONE DISCO E SISTEMA
:: ===================================

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
timeout /t 2 >nul
exit