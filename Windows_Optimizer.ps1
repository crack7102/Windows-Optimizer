# -----------------------------------
# Controllo privilegi amministratore
# -----------------------------------

# Controllo privilegi amministratore
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator"))
{
    Start-Process powershell `
        -ArgumentList "-NoProfile -NoLogo -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    Exit
}

# =========================================
# Launcher portatile: WOfetch + Windows Optimizer
# =========================================

# Sfondo nero
$host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

$logoColor   = "Cyan"
$labelColor  = "Gray"
$valueColor  = "White"

# Logo Windows 10 ASCII
$logo = @(
"                           ....iilll",
"                 ....iilllllllllllll",
"     ....iillll  lllllllllllllllllll",
" iillllllllllll  lllllllllllllllllll",
" llllllllllllll  lllllllllllllllllll",
" llllllllllllll  lllllllllllllllllll",
" llllllllllllll  lllllllllllllllllll",
" llllllllllllll  lllllllllllllllllll",
" llllllllllllll  lllllllllllllllllll",
"",
" llllllllllllll  lllllllllllllllllll",
" llllllllllllll  lllllllllllllllllll",
" llllllllllllll  lllllllllllllllllll",
" llllllllllllll  lllllllllllllllllll",
" llllllllllllll  lllllllllllllllllll",
" `^^^^^^llllllll  lllllllllllllllllll",
"       ``````^^^^   ^llllllllllllllllll",
"                        ````^^^iiillll"
"                                 ''' "
)

# =========================================
# Raccolta info sistema
# =========================================

$os       = Get-CimInstance Win32_OperatingSystem
$cpu      = Get-CimInstance Win32_Processor
$gpu      = Get-CimInstance Win32_VideoController | Select-Object -First 1
$ramTotal = [math]::Round($os.TotalVisibleMemorySize / 1KB / 1024, 1)
$disk     = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$bios     = Get-CimInstance Win32_BIOS
$board    = Get-CimInstance Win32_BaseBoard

# Risoluzione schermo
Add-Type -AssemblyName System.Windows.Forms
$screen = [System.Windows.Forms.Screen]::PrimaryScreen
$resolution = "$($screen.Bounds.Width)x$($screen.Bounds.Height)"

# Variabile user@PC
$userHost = "$env:USERNAME@$env:COMPUTERNAME"

# Memory dettagliata
$ramUsedMB = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1KB, 0)
$ramTotalMB = [math]::Round($os.TotalVisibleMemorySize / 1KB, 0)
$ramPercent = [math]::Round(($ramUsedMB / $ramTotalMB) * 100, 0)
$memoryDisplay = "$ramUsedMB MB / $ramTotalMB MB ($ramPercent% in use)"

# Disk dettagliato
$diskTotalGB = [math]::Round($disk.Size / 1GB, 2)
$diskFreeGB  = [math]::Round($disk.FreeSpace / 1GB, 2)
$diskDisplay = "C:\ $diskTotalGB GB ($diskFreeGB GB free)"

# OS con architettura
$osBit = $os.OSArchitecture
$osDisplay = "$($os.Caption) ($osBit)"

# Lista info ordinate
$infoList = @(
    @{Label="OS" ; Value="$osDisplay"},
    @{Label="Resolution" ; Value="$resolution"},
    @{Label="Memory" ; Value="$memoryDisplay"},
    @{Label="Disk" ; Value="$diskDisplay"},
    @{Label="CPU" ; Value="$($cpu.Name) ($($cpu.NumberOfCores) cores)"},
    @{Label="GPU" ; Value="$($gpu.Name)"},
    @{Label="BIOS" ; Value="$($bios.SMBIOSBIOSVersion)"},
    @{Label="Motherboard" ; Value="$($board.Product) - $($board.Manufacturer)"}
)

# Numero massimo di righe tra logo e info (+2 per utente e linea)
$max = [Math]::Max($logo.Count, $infoList.Count + 2)

# Stampa logo a sinistra e info a destra
for ($i = 0; $i -lt $max; $i++) {
    $logoLine = if ($i -lt $logo.Count) { $logo[$i] } else { "" }

    Write-Host ($logoLine.PadRight(40)) -ForegroundColor $logoColor -NoNewline

    if ($i -eq 0) {
        # Prima riga: solo utente@PC
        Write-Host $userHost -ForegroundColor $valueColor
    }
    elseif ($i -eq 1) {
        # Linea orizzontale sotto l'utente
        Write-Host "----------------------" -ForegroundColor $labelColor
    }
    else {
        # Info ordinate
        $infoIndex = $i - 2
        if ($infoIndex -lt $infoList.Count) {
            $infoItem = $infoList[$infoIndex]
            $label = $infoItem.Label.PadRight(12)
            Write-Host ($label + ": ") -ForegroundColor $labelColor -NoNewline
            Write-Host $infoItem.Value -ForegroundColor $valueColor
        } else {
            Write-Host ""
        }
    }
}

# Pausa solo se siamo in una console reale
if ($Host.Name -eq 'ConsoleHost') {
    Write-Host "`nPremi un tasto per avviare Windows Optimizer..." -ForegroundColor Gray
    [void][System.Console]::ReadKey($true)
} else {
    Start-Sleep -Seconds 2
}


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===================================
# Funzione per creare pulsanti con icona
# ===================================
function Create-Button($text, $x, $y, $width, $height, $action, $iconPath=$null) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size($width,$height)
    $btn.Location = New-Object System.Drawing.Point($x,$y)
    $btn.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)
    
    # Colore pulsante e stile
    $btn.BackColor = [System.Drawing.Color]::LightGray        # sfondo grigio chiaro
    $btn.ForeColor = [System.Drawing.Color]::Black           # testo nero
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderSize = 1                        # bordo sottile standard (grigio predefinito)

    # Azione click
    $btn.Add_Click($action)

    # Icona opzionale
    if ($iconPath -and (Test-Path $iconPath)) {
        $bmp = [System.Drawing.Bitmap]::FromFile($iconPath)
        $bmp = New-Object System.Drawing.Bitmap($bmp, [System.Drawing.Size]::new(32,32))
        $btn.Image = $bmp
        $btn.ImageAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $btn.TextImageRelation = [System.Windows.Forms.TextImageRelation]::ImageBeforeText
    }

    return $btn
}

# ===================================
# Funzione punto di ripristino con MessageBox e "in corso" automatico
# ===================================
function Create-RestorePoint($lang) {
    # Testi per lingua
    $msg = ""
    $inProgressText = ""
    $completedText = ""

    switch ($lang) {
        "ITA" { 
            $msg = "Vuoi creare un punto di ripristino completo prima di procedere?`n(consigliato prima di modifiche al sistema)"
            $inProgressText = "Creazione punto di ripristino in corso..."
            $completedText = "Punto di ripristino completato con successo!"
        }
        "ENG" { 
            $msg = "Do you want to create a full restore point before proceeding?`n(recommended before system changes)"
            $inProgressText = "Restore point creation in progress..."
            $completedText = "Restore point completed successfully!"
        }
        "ESP" { 
            $msg = "¿Deseas crear un punto de restauración completo antes de continuar?`n(recomendado antes de cambios en el sistema)"
            $inProgressText = "Creación del punto de restauración en curso..."
            $completedText = "¡Punto de restauración completado con éxito!"
        }
    }

    # Chiedi conferma con MessageBox Sì/No
    $result = [System.Windows.Forms.MessageBox]::Show($msg, "Windows Optimizer", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        # Finestra "In corso" senza pulsanti
        $formProgress = New-Object System.Windows.Forms.Form
        $formProgress.Text = "Windows Optimizer"
        $formProgress.Size = New-Object System.Drawing.Size(320,100)
        $formProgress.StartPosition = "CenterScreen"
        $formProgress.FormBorderStyle = "FixedDialog"
        $formProgress.Topmost = $true
        $formProgress.ControlBox = $false  # Rimuove pulsanti chiudi/minimizza

        $lblProgress = New-Object System.Windows.Forms.Label
        $lblProgress.Text = $inProgressText
        $lblProgress.Font = New-Object System.Drawing.Font("Arial",11,[System.Drawing.FontStyle]::Bold)
        $lblProgress.AutoSize = $true
        $lblProgress.Location = New-Object System.Drawing.Point(20,20)
        $formProgress.Controls.Add($lblProgress)

        $formProgress.Show()
        $formProgress.Refresh()

        # Creazione punto di ripristino
        try {
            powershell -Command "Checkpoint-Computer -Description 'Punto di Ripristino Pre Ottimizzazione'"
        } catch {
            $formProgress.Close()
            [System.Windows.Forms.MessageBox]::Show('Errore nella creazione del punto di ripristino.','Errore',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        # Chiudi automaticamente il messaggio "In corso"
        $formProgress.Close()

        # Finestra completato in primo piano
        [System.Windows.Forms.MessageBox]::Show($completedText,"Info",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information,[System.Windows.Forms.MessageBoxDefaultButton]::Button1,[System.Windows.Forms.MessageBoxOptions]::DefaultDesktopOnly)
    }
}

# ===================================
# Funzione Aggiornamento App multilingua senza BAT
# ===================================
function Update-Apps($lang) {

    switch ($lang) {
        "ITA" { $text = "Apertura in corso..." }
        "ENG" { $text = "Opening in progress..." }
        "ESP" { $text = "Apertura en curso..." }
    }

    # Recupera menu principale
    $menu = [System.Windows.Forms.Application]::OpenForms |
            Where-Object { $_.Tag -eq "MAINMENU" }

    # RILASCIA IL FOCUS (passaggio chiave)
    if ($menu) {
        $menu.Topmost = $false
        $menu.Hide()
        [System.Windows.Forms.Application]::DoEvents()
    }

    # Messaggio temporaneo (non blocca focus)
    $msgForm = New-Object System.Windows.Forms.Form
    $msgForm.Text = "Windows Optimizer"
    $msgForm.Size = New-Object System.Drawing.Size(200,90)
    $msgForm.StartPosition = "CenterScreen"
    $msgForm.FormBorderStyle = "FixedDialog"
    $msgForm.ControlBox = $false
    $msgForm.Topmost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $text
    $label.Font = New-Object System.Drawing.Font("Arial",11,[System.Drawing.FontStyle]::Bold)
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(20,25)
    $msgForm.Controls.Add($label)

    $msgForm.Show()
    $msgForm.Refresh()

    # Winget
    $psCommand = @"
winget update
winget upgrade --all --accept-package-agreements --accept-source-agreements
"@

    $proc = Start-Process powershell `
        -ArgumentList "-Command",$psCommand `
        -Verb RunAs `
        -WindowStyle Normal `
        -PassThru

    # Chiude messaggio
    Start-Sleep -Milliseconds 600
    $msgForm.Close()

    # Attende fine PowerShell
    $proc.WaitForExit()

    # Ripristina menu
    if ($menu) {
        $menu.Show()
        $menu.Activate()
    }
}
# ===================================
# Menu Principale
# ===================================
function ShowMenu($lang) {

    # ============================
    # Percorsi portabili
    # ============================
    $UtilityPath = Join-Path $PSScriptRoot "Utility"

    # ============================
    # Form principale
    # ============================
    $formMenu = New-Object System.Windows.Forms.Form
    $formMenu.Size = New-Object System.Drawing.Size(500,700)
    $formMenu.StartPosition = "CenterScreen"
    $formMenu.FormBorderStyle = "FixedDialog"
    $formMenu.MaximizeBox = $false
    $formMenu.MinimizeBox = $true
    $formMenu.ShowInTaskbar = $true

    $labelMenu = New-Object System.Windows.Forms.Label
    $labelMenu.Font = New-Object System.Drawing.Font("Arial",11,[System.Drawing.FontStyle]::Bold)
    $labelMenu.AutoSize = $true
    $labelMenu.Location = New-Object System.Drawing.Point(50,20)
    $formMenu.Controls.Add($labelMenu)

    # ============================
    # Funzione helper pulsanti
    # ============================
    function Add-BatButton($text, $y, $action) {
        $btn = Create-Button $text 40 $y 400 50 $action
        $formMenu.Controls.Add($btn)
    }

    $exitText = ""

    # ============================
# Menu Multilingua
# ============================
switch ($lang) {
    "ITA" {
        $formMenu.Text = "Windows Optimizer by Riccardo Ferrini"
        $labelMenu.Text = "MENÙ PRINCIPALE"

        Add-BatButton "Pulizia file temporanei" 60 { Start-Process (Join-Path $UtilityPath "PuliziaITA.bat") -Verb RunAs }
        Add-BatButton "Ottimizzazione disco e sistema" 115 { Start-Process (Join-Path $UtilityPath "OttimizzaITA.bat") -Verb RunAs }
        Add-BatButton "Installa Microsoft Visual C++ Redistributable e DirectX 11" 170 { Run-RedistSequence "ITA" }
        Add-BatButton "Tweak - Ottimizzazioni Windows" 225 { Show-TweakMenu "ITA" }
        Add-BatButton "Gestione servizi Windows" 280 { Start-Process (Join-Path $UtilityPath "ServiziITA.bat") -Verb RunAs }
        Add-BatButton "Aggiornamento app" 335 { Update-Apps "ITA" }
        Add-BatButton "Disinstalla App" 390 { Start-Process (Join-Path $UtilityPath "DisinstallaAppITA.bat") -Verb RunAs }
        Add-BatButton "Installatore Multi App" 445 { Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$UtilityPath\MultiApp.ps1`"" -Verb RunAs }
        Add-BatButton "Strumenti extra" 500 {
            $p = Join-Path $PSScriptRoot "Extra"
            New-Item -ItemType Directory -Path $p -Force | Out-Null
            Start-Process explorer.exe $p
        }

        $exitText = "Esci"
    }

    "ENG" {
        $formMenu.Text = "Windows Optimizer by Riccardo Ferrini"
        $labelMenu.Text = "MAIN MENU"

        Add-BatButton "Temporary files cleanup" 60 { Start-Process (Join-Path $UtilityPath "PuliziaENG.bat") -Verb RunAs }
        Add-BatButton "Disk and system optimization" 115 { Start-Process (Join-Path $UtilityPath "OttimizzaENG.bat") -Verb RunAs }
        Add-BatButton "Install Visual C++ Redistributable and DirectX 11" 170 { Run-RedistSequence "ENG" }
        Add-BatButton "Tweak - Windows optimization" 225 { Show-TweakMenu "ENG" }
        Add-BatButton "Windows services management" 280 { Start-Process (Join-Path $UtilityPath "ServiziENG.bat") -Verb RunAs }
        Add-BatButton "App update" 335 { Update-Apps "ENG" }
        Add-BatButton "Uninstall App" 390 { Start-Process (Join-Path $UtilityPath "DisinstallaAppENG.bat") -Verb RunAs }
        Add-BatButton "Multi App installer" 445 { Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$UtilityPath\MultiApp.ps1`"" -Verb RunAs }
        Add-BatButton "Extra tools" 500 {
            $p = Join-Path $PSScriptRoot "Extra"
            New-Item -ItemType Directory -Path $p -Force | Out-Null
            Start-Process explorer.exe $p
        }

        $exitText = "Exit"
    }

    "ESP" {
        $formMenu.Text = "Windows Optimizer by Riccardo Ferrini"
        $labelMenu.Text = "MENÚ PRINCIPAL"

        Add-BatButton "Limpieza de archivos temporales" 60 { Start-Process (Join-Path $UtilityPath "PuliziaESP.bat") -Verb RunAs }
        Add-BatButton "Optimización de disco y sistema" 115 { Start-Process (Join-Path $UtilityPath "OttimizzaESP.bat") -Verb RunAs }
        Add-BatButton "Instalar Visual C++ Redistributable y DirectX 11" 170 { Run-RedistSequence "ESP" }
        Add-BatButton "Tweak - Optimización de Windows" 225 { Show-TweakMenu "ESP" }
        Add-BatButton "Gestión de servicios de Windows" 280 { Start-Process (Join-Path $UtilityPath "ServiziESP.bat") -Verb RunAs }
        Add-BatButton "Actualización de aplicaciones" 335 { Update-Apps "ESP" }
        Add-BatButton "Desinstalar App" 390 { Start-Process (Join-Path $UtilityPath "DisinstallaAppESP.bat") -Verb RunAs }
        Add-BatButton "Instalador Multi App" 445 { Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$UtilityPath\MultiApp.ps1`"" -Verb RunAs }
        Add-BatButton "Herramientas extra" 500 {
            $p = Join-Path $PSScriptRoot "Extra"
            New-Item -ItemType Directory -Path $p -Force | Out-Null
            Start-Process explorer.exe $p
        }

        $exitText = "Salir"
    }
}
    # ============================
    # Pulsante Esci
    # ============================
    $exitButton = Create-Button $exitText 40 580 400 50 { $formMenu.Close() }
    $formMenu.Controls.Add($exitButton)

    $formMenu.Topmost = $false
    $formMenu.Add_Shown({$formMenu.Activate()})
    [void]$formMenu.ShowDialog()
}

# ===================================
# Finestra "Apertura in corso"
# ===================================
function Show-OpeningMessage($text) {
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Windows Optimizer"
    $f.Size = "230,90"
    $f.FormBorderStyle = "FixedDialog"
    $f.ControlBox = $false
    $f.StartPosition = "CenterScreen"
    $f.Topmost = $true

    $l = New-Object System.Windows.Forms.Label
    $l.Text = $text
    $l.Font = New-Object System.Drawing.Font("Arial",11,[System.Drawing.FontStyle]::Bold)
    $l.AutoSize = $true
    $l.Location = "30,25"
    $l.StartPosition = "CenterScreen"

    $f.Controls.Add($l)
    $f.Show()
    $f.Refresh()
    return $f
}

# ===================================
# REDIST + DIRECTX (Utility\Runtimes)
# ===================================
function Run-RedistSequence($lang) {

    switch ($lang) {
        "ITA" { $msg="Apertura in corso..." }
        "ENG" { $msg="Opening in progress..." }
        "ESP" { $msg="Apertura en curso..." }
    }

    $rt = Join-Path $PSScriptRoot "Utility\Runtimes"

    # REDIST
    $f1 = Show-OpeningMessage $msg
    Start-Sleep -Milliseconds 400
    $p1 = Start-Process (Join-Path $rt "Microsoft Visual C++ Redist Package.exe") -PassThru
    $f1.Close()
    $p1.WaitForExit()

    # DIRECTX
    $f2 = Show-OpeningMessage $msg
    Start-Sleep -Milliseconds 400
    Start-Process (Join-Path $rt "DirectX End-User Runtimes (June 2010).exe")
    $f2.Close()
}

# ===================================
# Finestra TWEAK
# ===================================
function Show-TweakMenu($lang) {

    $f = New-Object System.Windows.Forms.Form
    $f.Size = "400,560"
    $f.FormBorderStyle = "FixedDialog"
    $f.StartPosition = "CenterScreen"
    $f.MaximizeBox = $false

    # --------- Testi multilingua ---------
    switch ($lang) {
        "ITA" { 
            $f.Text = "Tweak Windows"; 
            $exit = "Menu principale"
            $tweaks = @(
                "Aspetto e prestazioni Windows",
                "Opzioni energia - Prestazioni",
                "Sistema Audio",
                "Attiva la Modalità Gioco",
                "Disattiva App in background",
                "Disattiva Trasparenza",
                "Ottimizza CPU e GPU",
                "Disattiva Windows Insider",
                "Rimuovi Windows AI"
            )
            $cpuBat = "CPUFixITA.bat"
            $insiderBat = "DisattivaInsiderITA.bat"
            $msgConfirmAppearance = "Vuoi aprire le Opzioni Prestazioni di Windows?"
            $msgConfirmPower = "Vuoi attivare Prestazioni elevate?"
            $msgSuccessPower = "Prestazioni elevate attivate con successo!"
            $msgConfirmBackground = "Vuoi disattivare tutte le app in background?"
            $msgSuccessBackground = "App in background disattivate con successo!"
            $msgConfirmTransparency = "Vuoi disattivare la trasparenza di Windows?"
            $msgSuccessTransparency = "Trasparenza disattivata con successo!"
            $msgConfirmCPU = "Vuoi applicare l'ottimizzazione CPU/GPU?"
            $msgSuccessCPU = "Ottimizzazione CPU/GPU avvenuta con successo!"
            $msgConfirmInsider = "Vuoi disattivare Windows Insider?"
            $msgSuccessInsider = "Windows Insider disattivato con successo!"
            $msgConfirmAI = "Vuoi rimuovere Windows AI?"
            $msgSuccessAI = "Windows AI rimosso con successo!"
            $msgErrorFile = "File non trovato"
        }
        "ENG" { 
            $f.Text = "Windows Tweaks"; 
            $exit = "Main menu"
            $tweaks = @(
                "Windows appearance and performance",
                "Power options - High Performance",
                "Audio Settings",
                "Enable Game Mode",
                "Disable Background Apps",
                "Disable Transparency",
                "CPU and GPU Optimization",
                "Disable Windows Insider",
                "Remove Windows AI"
            )
            $cpuBat = "CPUFixENG.bat"
            $insiderBat = "DisattivaInsiderENG.bat"
            $msgConfirmAppearance = "Do you want to open Windows Performance Options?"
            $msgConfirmPower = "Do you want to enable High Performance?"
            $msgSuccessPower = "High Performance enabled successfully!"
            $msgConfirmBackground = "Do you want to disable all background apps?"
            $msgSuccessBackground = "Background apps disabled successfully!"
            $msgConfirmTransparency = "Do you want to disable Windows transparency?"
            $msgSuccessTransparency = "Transparency disabled successfully!"
            $msgConfirmCPU = "Do you want to apply CPU/GPU optimization?"
            $msgSuccessCPU = "CPU/GPU optimization applied successfully!"
            $msgConfirmInsider = "Do you want to disable Windows Insider?"
            $msgSuccessInsider = "Windows Insider disabled successfully!"
            $msgConfirmAI = "Do you want to remove Windows AI?"
            $msgSuccessAI = "Windows AI removed successfully!"
            $msgErrorFile = "File not found"
        }
        "ESP" { 
            $f.Text = "Tweak Windows"; 
            $exit = "Menú principal"
            $tweaks = @(
                "Modificar Apariencia y rendimiento",
                "Energía - Alto rendimiento",
                "Sistema de audio",
                "Activar Modo Juego",
                "Desactivar apps en segundo plano",
                "Desactivar transparencia",
                "Optimización CPU y GPU",
                "Desactivar Windows Insider",
                "Eliminar Windows AI"
            )
            $cpuBat = "CPUFixESP.bat"
            $insiderBat = "DisattivaInsiderESP.bat"
            $msgConfirmAppearance = "¿Desea abrir las Opciones de Rendimiento de Windows?"
            $msgConfirmPower = "¿Desea activar Alto Rendimiento?"
            $msgSuccessPower = "Alto Rendimiento activado con éxito!"
            $msgConfirmBackground = "¿Desea desactivar todas las aplicaciones en segundo plano?"
            $msgSuccessBackground = "Aplicaciones en segundo plano desactivadas con éxito!"
            $msgConfirmTransparency = "¿Desea desactivar la transparencia de Windows?"
            $msgSuccessTransparency = "Transparencia desactivada con éxito!"
            $msgConfirmCPU = "¿Desea aplicar la optimización CPU/GPU?"
            $msgSuccessCPU = "Optimización CPU/GPU aplicada con éxito!"
            $msgConfirmInsider = "¿Desea desactivar Windows Insider?"
            $msgSuccessInsider = "Windows Insider desactivado con éxito!"
            $msgConfirmAI = "¿Desea eliminar Windows AI?"
            $msgSuccessAI = "Windows AI eliminado con éxito!"
            $msgErrorFile = "Archivo no encontrado"
        }
    }

    # --------- Funzione per aggiungere pulsanti ---------
    function AddTweak($txt,$y,$action) {
        $f.Controls.Add((Create-Button $txt 10 $y 360 40 $action))
    }

    # --------- Azioni dei pulsanti ---------
    $audioAction = { Start-Process "control.exe" "mmsys.cpl" }

    $appearanceAction = {
        $confirm = [System.Windows.Forms.MessageBox]::Show($msgConfirmAppearance,"Confirm",[System.Windows.Forms.MessageBoxButtons]::OKCancel,[System.Windows.Forms.MessageBoxIcon]::Question)
        if ($confirm -eq [System.Windows.Forms.DialogResult]::OK) { Start-Process "SystemPropertiesPerformance.exe" }
    }

    $powerAction = {
        $confirm = [System.Windows.Forms.MessageBox]::Show($msgConfirmPower,"Confirm",[System.Windows.Forms.MessageBoxButtons]::OKCancel,[System.Windows.Forms.MessageBoxIcon]::Question)
        if ($confirm -eq [System.Windows.Forms.DialogResult]::OK) {
            powercfg -setactive SCHEME_MIN
            [System.Windows.Forms.MessageBox]::Show($msgSuccessPower,"Info",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
        }
    }

    $backgroundAppsAction = {
        $confirm = [System.Windows.Forms.MessageBox]::Show($msgConfirmBackground,"Confirm",[System.Windows.Forms.MessageBoxButtons]::OKCancel,[System.Windows.Forms.MessageBoxIcon]::Question)
        if ($confirm -eq [System.Windows.Forms.DialogResult]::OK) {
            Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" | ForEach-Object {
                Set-ItemProperty -Path $_.PSPath -Name "GlobalUserDisabled" -Value 1
            }
            [System.Windows.Forms.MessageBox]::Show($msgSuccessBackground,"Info",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
        }
    }

    $transparencyAction = {
        $confirm = [System.Windows.Forms.MessageBox]::Show($msgConfirmTransparency,"Confirm",[System.Windows.Forms.MessageBoxButtons]::OKCancel,[System.Windows.Forms.MessageBoxIcon]::Question)
        if ($confirm -eq [System.Windows.Forms.DialogResult]::OK) {
            Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0
            [System.Windows.Forms.MessageBox]::Show($msgSuccessTransparency,"Info",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
        }
    }

    $cpuGpuAction = {
        $bat = "$PSScriptRoot\Utility\$cpuBat"
        if (Test-Path $bat) {
            $confirm = [System.Windows.Forms.MessageBox]::Show($msgConfirmCPU,"Confirm",[System.Windows.Forms.MessageBoxButtons]::OKCancel,[System.Windows.Forms.MessageBoxIcon]::Question)
            if ($confirm -eq [System.Windows.Forms.DialogResult]::OK) {
                Start-Process $bat -Wait
                [System.Windows.Forms.MessageBox]::Show($msgSuccessCPU,"Info",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
            }
        } else { [System.Windows.Forms.MessageBox]::Show("$cpuBat - $msgErrorFile","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) }
    }

    $insiderAction = {
        $bat = "$PSScriptRoot\Utility\$insiderBat"
        if (Test-Path $bat) {
            $confirm = [System.Windows.Forms.MessageBox]::Show($msgConfirmInsider,"Confirm",[System.Windows.Forms.MessageBoxButtons]::OKCancel,[System.Windows.Forms.MessageBoxIcon]::Question)
            if ($confirm -eq [System.Windows.Forms.DialogResult]::OK) {
                Start-Process $bat -Wait
                [System.Windows.Forms.MessageBox]::Show($msgSuccessInsider,"Info",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
            }
        } else { [System.Windows.Forms.MessageBox]::Show("$insiderBat - $msgErrorFile","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) }
    }

    $removeAIAction = {
        $ps1 = "$PSScriptRoot\Utility\RemoveWindowsAI.ps1"
        if (Test-Path $ps1) {
            $confirm = [System.Windows.Forms.MessageBox]::Show($msgConfirmAI,"Confirm",[System.Windows.Forms.MessageBoxButtons]::OKCancel,[System.Windows.Forms.MessageBoxIcon]::Question)
            if ($confirm -eq [System.Windows.Forms.DialogResult]::OK) {
                Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$ps1`"" -Wait
                [System.Windows.Forms.MessageBox]::Show($msgSuccessAI,"Info",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
            }
        } else { [System.Windows.Forms.MessageBox]::Show("RemoveWindowsAI.ps1 - $msgErrorFile","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) }
    }

# ---------- Modalità Gioco----------
$gameModeAction = {
    switch ($lang) {
        "ITA" { $msgConfirm = "Vuoi attivare la Modalità Gioco?"; $msgSuccess = "Modalità Gioco attivata con successo!" }
        "ENG" { $msgConfirm = "Do you want to enable Game Mode?"; $msgSuccess = "Game Mode enabled successfully!" }
        "ESP" { $msgConfirm = "¿Desea activar el Modo Juego?"; $msgSuccess = "Modo Juego activado con éxito!" }
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        $msgConfirm,
        "Confirm",
        [System.Windows.Forms.MessageBoxButtons]::OKCancel,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($confirm -eq [System.Windows.Forms.DialogResult]::OK) {

        # ---- Creazione chiavi HKLM/HKCU se non esistono ----
        $pathLM = "HKLM:\SOFTWARE\Microsoft\GameBar"
        if (-not (Test-Path $pathLM)) { New-Item -Path $pathLM -Force | Out-Null }

        $pathCU = "HKCU:\Software\Microsoft\GameBar"
        if (-not (Test-Path $pathCU)) { New-Item -Path $pathCU -Force | Out-Null }

        # ---- Imposta valori DWORD ----
        New-ItemProperty -Path $pathLM -Name "AllowAutoGameMode" -PropertyType DWord -Value 1 -Force
        New-ItemProperty -Path $pathCU -Name "AutoGameModeEnabled" -PropertyType DWord -Value 1 -Force

        # ---- Messaggio di conferma ----
        [System.Windows.Forms.MessageBox]::Show(
            $msgSuccess,
            "Info",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    }
}

    $defaultAction = { [System.Windows.Forms.MessageBox]::Show("Function not implemented yet","Info",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) }

    # --------- Aggiunge i pulsanti ----------
    $yPos = 15
    foreach ($t in $tweaks) {
        switch ($t) {
            "Sistema Audio" { AddTweak $t $yPos $audioAction }
            "Audio Settings" { AddTweak $t $yPos $audioAction }
            "Sistema de audio" { AddTweak $t $yPos $audioAction }

            "Aspetto e prestazioni Windows" { AddTweak $t $yPos $appearanceAction }
            "Windows appearance and performance" { AddTweak $t $yPos $appearanceAction }
            "Modificar Apariencia y rendimiento" { AddTweak $t $yPos $appearanceAction }

            "Opzioni energia - Prestazioni" { AddTweak $t $yPos $powerAction }
            "Power options - High Performance" { AddTweak $t $yPos $powerAction }
            "Energía - Alto rendimiento" { AddTweak $t $yPos $powerAction }

            "Attiva la Modalità Gioco" { AddTweak $t $yPos $gameModeAction }
            "Enable Game Mode" { AddTweak $t $yPos $gameModeAction }
            "Activar Modo Juego" { AddTweak $t $yPos $gameModeAction }

            "Disattiva App in background" { AddTweak $t $yPos $backgroundAppsAction }
            "Disable Background Apps" { AddTweak $t $yPos $backgroundAppsAction }
            "Desactivar apps en segundo plano" { AddTweak $t $yPos $backgroundAppsAction }

            "Disattiva Trasparenza" { AddTweak $t $yPos $transparencyAction }
            "Disable Transparency" { AddTweak $t $yPos $transparencyAction }
            "Desactivar transparencia" { AddTweak $t $yPos $transparencyAction }

            "Ottimizza CPU e GPU" { AddTweak $t $yPos $cpuGpuAction }
            "CPU and GPU Optimization" { AddTweak $t $yPos $cpuGpuAction }
            "Optimización CPU y GPU" { AddTweak $t $yPos $cpuGpuAction }

            "Disattiva Windows Insider" { AddTweak $t $yPos $insiderAction }
            "Disable Windows Insider" { AddTweak $t $yPos $insiderAction }
            "Desactivar Windows Insider" { AddTweak $t $yPos $insiderAction }

            "Rimuovi Windows AI" { AddTweak $t $yPos $removeAIAction }
            "Remove Windows AI" { AddTweak $t $yPos $removeAIAction }
            "Eliminar Windows AI" { AddTweak $t $yPos $removeAIAction }

            default { AddTweak $t $yPos $defaultAction }
        }
        $yPos += 45
    }

    # Pulsante uscita
    $yPos += 40
    $f.Controls.Add((Create-Button $exit 10 $yPos 360 40 { $f.Close() }))

    $f.ShowDialog()
}

# ===================================
# Form scelta lingua con benvenuto e restore point
# ===================================

$formLang = New-Object System.Windows.Forms.Form
$formLang.Text = "Windows Optimizer – Language Selection"
$formLang.Size = New-Object System.Drawing.Size(410,160)
$formLang.StartPosition = "CenterScreen"
$formLang.FormBorderStyle = "FixedDialog"
$formLang.MaximizeBox = $false
$formLang.MinimizeBox = $false
$formLang.AutoScaleMode = "Dpi"

$labelLang = New-Object System.Windows.Forms.Label
$labelLang.Text = "Scegli la lingua / Select your language / Elegir idioma"
$labelLang.Font = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Bold)
$labelLang.AutoSize = $true
$labelLang.Location = New-Object System.Drawing.Point(25,15)
$formLang.Controls.Add($labelLang)

$iconsPath = Join-Path $PSScriptRoot "Utility\WOIcons"
$btnWidth = 112
$btnHeight = 50
$spacing = 10
$startX = 20
$yPos = 55

# =====================
# Italiano
# =====================
$btnITA = Create-Button "Italiano" $startX $yPos $btnWidth $btnHeight {
    $formLang.Close()

    $welcomeText = @"
BENVENUTO

Questo programma serve a:
- Rimuovere file temporanei, cache e dati non necessari per velocizzare il PC
- Migliorare le prestazioni di Windows
- Gestire e disattivare servizi di Windows inutili
- Fornire programmi aggiuntivi nella sezione Extra

Premi OK per continuare...
"@

    [System.Windows.Forms.MessageBox]::Show(
        $welcomeText,
        "Windows Optimizer",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )

    try {
        Create-RestorePoint "ITA"
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Impossibile creare il punto di ripristino.`nSi continua comunque.",
            "Avviso",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    }

    ShowMenu "ITA"
} "$iconsPath\itaflag.png"

# =====================
# English
# =====================
$btnENG = Create-Button "English" ($startX + $btnWidth + $spacing) $yPos $btnWidth $btnHeight {
    $formLang.Close()

    $welcomeText = @"
WELCOME

This tool helps you to:
- Remove temporary files, cache, and unnecessary data to speed up your PC
- Improve Windows performance
- Manage and disable unnecessary Windows services
- Provide additional programs in the Extras section

Press OK to continue...
"@

    [System.Windows.Forms.MessageBox]::Show(
        $welcomeText,
        "Windows Optimizer",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )

    try {
        Create-RestorePoint "ENG"
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Unable to create a restore point.`nContinuing anyway.",
            "Warning",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    }

    ShowMenu "ENG"
} "$iconsPath\engflag.png"

# =====================
# Español
# =====================
$btnESP = Create-Button "Español" ($startX + ($btnWidth + $spacing)*2) $yPos $btnWidth $btnHeight {
    $formLang.Close()

    $welcomeText = @"
BIENVENIDO

Este programa sirve para:
- Eliminar archivos temporales, caché y datos innecesarios para acelerar el PC
- Mejorar el rendimiento de Windows
- Gestionar y desactivar servicios de Windows innecesarios
- Proporcionar programas adicionales en la sección Extra

Presiona OK para continuar...
"@

    [System.Windows.Forms.MessageBox]::Show(
        $welcomeText,
        "Windows Optimizer",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )

    try {
        Create-RestorePoint "ESP"
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "No se pudo crear el punto de restauración.`nContinuando.",
            "Aviso",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    }

    ShowMenu "ESP"
} "$iconsPath\espflag.png"

$formLang.Controls.AddRange(@($btnITA,$btnENG,$btnESP))
$formLang.Topmost = $false
$formLang.Add_Shown({ $formLang.Activate() })
[void]$formLang.ShowDialog()