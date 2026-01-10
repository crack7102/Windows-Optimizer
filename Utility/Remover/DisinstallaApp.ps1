# =========================================
#   RIMOZIONE APP PREINSTALLATE WINDOWS
# =========================================

# Controllo privilegi amministratore
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator"))
{
    Write-Host "Rilancio lo script come amministratore..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
$ErrorActionPreference = "SilentlyContinue"

# Lista app da rimuovere
$apps = @(
"AdobeSystemsIncorporated.AdobePhotoshopExpress",
"7EE7776C.LinkedInforWindows",     # LinkedIn for Windows
"Clipchamp.Clipchamp",
"king.com.CandyCrushSaga","king.com.CandyCrushSodaSaga","king.com.BubbleWitch3Saga",
"MicrosoftCorporationII.QuickAssist",
"Facebook.Facebook",     # Facebook
"4DF9E0F8.Netflix",     # Netflix
"CAF9E577.Plex","Plex.Plex",     # Plex
"Evernote.Evernote",     # Evernote
"KeeperSecurityInc.Keeper","KeeperSecurity.KeeperDesktop",     # Keeper
"Microsoft.3DBuilder",     # 3D Builder
"Microsoft.BingFinance","Microsoft.BingNews","Microsoft.BingSports","Microsoft.BingTranslator",     # Bing     
"Microsoft.BingWeather","Microsoft.BingWallpaper","Microsoft.MakeBingYourSearchEngine",     # Bing
"Microsoft.BingFoodAndDrink", "Microsoft.BingHealthAndFitness", "Microsoft.BingTravel",     # Bing
"Microsoft.Copilot",
"Microsoft.Cortana", "Microsoft.549981C3F5F10",     # Cortana
"Microsoft.Windows.DevHome","Microsoft.DevHome",     # DevHome
"Microsoft.Appconnector",
"Microsoft.GetHelp",
"Microsoft.Getstarted",
"Microsoft.Microsoft3DViewer",
"Microsoft.MicrosoftSolitaireCollection",     # Microsoft Solitaire Collection
"Microsoft.MicrosoftStickyNotes",     # Microsoft Sticky Notes
"Microsoft.Messaging",     # Messaggi
"Microsoft.MixedReality.Portal",
"Microsoft.MSPaint", "Microsoft.Paint",     # Microsoft Paint
"Microsoft.Windows.Photos",     # Microsoft Foto
"Microsoft.OfficeHub","Microsoft.Office.Launcher","Microsoft.Office.OneNote","Microsoft.Office.Outlook","Microsoft.OneConnect",     # Office
"Microsoft.People",
"Microsoft.PowerAutomateDesktop",
"Microsoft.Print3D",
"Microsoft.SkypeApp",     # Skype
"SpotifyAB.SpotifyMusic",     # Spotify
"Microsoft.Todos","Microsoft.Todo",     # Microsoft To Do
"TuneIn.TuneInRadio",     # TuneInRadio
"Microsoft.WindowsAlarms",     # Orologio
"Microsoft.WindowsFeedback","Microsoft.WindowsFeedbackHub",     # Hub di Feedback  
"microsoft.windowscommunicationsapps",
"Microsoft.WindowsMaps",
"Microsoft.WindowsSoundRecorder",     # Registratore vocale
"Microsoft.WindowsTerminal",     # Terminale
"Microsoft.YourPhone",     # Collegamento al Telefono
"Microsoft.XboxApp","Microsoft.GamingApp","Microsoft.XboxGameCallableUI","Microsoft.XboxGameOverlay","Microsoft.GamingServices",     # Xbox
"Microsoft.XboxGamingOverlay","Microsoft.XboxIdentityProvider","Microsoft.XboxSpeechToTextOverlay","Microsoft.Xbox.TCUI","Microsoft.XboxApp",   # Xbox
"Microsoft.ZuneMusic","Microsoft.ZuneVideo","Microsoft.Zune"     # Zune
)

# Esclusione app critiche
$excluded = @(
    "Microsoft.WindowsStore",     # Windows Store
    "Microsoft.MicrosoftEdge",     # Microsoft Edge
    "Microsoft.WindowsCamera",     # Fotocamera
    "Microsoft.WindowsCalculator",     # Calcolatrice
    "Microsoft.DesktopAppInstaller",     # App Installer
    "Microsoft.WinGet.Client"     # WinGet
)
$apps = $apps | Where-Object { $excluded -notcontains $_ }

# Controlla app installate
$installedPackages = Get-AppxPackage -AllUsers | Select-Object -ExpandProperty PackageFullName
$appsToRemove = @()
foreach ($app in $apps) {
    if ($installedPackages -match [regex]::Escape($app)) { $appsToRemove += $app }
}

$total = $appsToRemove.Count
if ($total -eq 0) { Write-Host "Nessuna app della lista è attualmente installata. Uscita."; exit }

# Barra di progresso
$barLength = 50
Clear-Host
Write-Host ("="*70)
Write-Host "            RIMOZIONE DELLE APP PREINSTALLATE DI WINDOWS"
Write-Host ("="*70)
Write-Host ""
Write-Host "Progresso:"

$barRow = [Console]::CursorTop
[Console]::SetCursorPosition(0, $barRow)
Write-Host ("[" + ("-"*$barLength) + "] 0%") -NoNewline

# Posizione per i messaggi "Rimuovendo"
$msgRow = $barRow + 1

# Rimozione pacchetti con barra e pausa 1 secondo tra rimuovendo
foreach ($app in $appsToRemove) {

    # Rimuove pacchetti Appx
    $packages = Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -like "*$app*" }
    foreach ($pkg in $packages) {
        Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue
        
        # Stampa "Rimuovendo" sotto la barra
        [Console]::SetCursorPosition(0, $msgRow)
        Write-Host ("Rimuovendo: " + $pkg.Name).PadRight([Console]::WindowWidth)
        $msgRow++
        
        Start-Sleep -Seconds 1
    }

    # Rimuove pacchetti Provisioned
    $provPackages = Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*$app*" }
    foreach ($prov in $provPackages) {
        Start-Process -FilePath dism.exe -ArgumentList "/Online","/Remove-ProvisionedAppxPackage","/PackageName:$($prov.PackageName)","/NoRestart" -WindowStyle Hidden -Wait
    }

    # Aggiorna barra senza spostare il messaggio
    $i = [array]::IndexOf($appsToRemove,$app)
    $filled = [int](($i+1)/$total*$barLength)
    $empty = $barLength - $filled
    $percent = [int](($i+1)/$total*100)
    [Console]::SetCursorPosition(0, $barRow)
    Write-Host ("[" + ("#"*$filled) + ("-"*$empty) + "] $percent%") -NoNewline
}

# Completa barra a 100%
[Console]::SetCursorPosition(0, $barRow)
Write-Host ("[" + ("#"*$barLength) + "] 100%")

# Pausa 1 secondo prima della fase residui e pulizia console
Start-Sleep -Seconds 1
Clear-Host

# Pulizia residui con pausa 1 secondo tra pacchetto e pacchetto
Write-Host "Eliminazione dei file residui delle app rimosse..."
$localPackages = "$env:LOCALAPPDATA\Packages"

foreach ($app in $appsToRemove) {
    $appFolders = Get-ChildItem $localPackages -Directory | Where-Object { $_.Name -like "*$app*" }
    foreach ($folder in $appFolders) { try { Remove-Item $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue } catch {} }
    Start-Sleep -Seconds 1

    $tempFolders = Get-ChildItem $env:TEMP -Directory | Where-Object { $_.Name -like "*$app*" }
    foreach ($folder in $tempFolders) { try { Remove-Item $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue } catch {} }
    Start-Sleep -Seconds 1
}

# Fine
Write-Host ""
Write-Host ("="*70)
Write-Host "Tutte le app inutili e i loro file sono stati eliminati con successo!"
Write-Host ("="*70)
Write-Host "Premi un tasto qualsiasi per chiudere..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")