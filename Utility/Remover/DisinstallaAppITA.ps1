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

Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   RIMOZIONE DELLE APP PREINSTALLATE DI WINDOWS   " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# -----------------------------------
# Lista app Microsoft da rimuovere
# -----------------------------------
$Bloatware = @(
    # ===============================
    # Adobe
    # ===============================
    "AdobeSystemsIncorporated.AdobePhotoshopExpress",   # Adobe Photoshop Express

    # ===============================
    # Social / Media
    # ===============================
    "7EE7776C.LinkedInforWindows",                       # LinkedIn for Windows
    "Facebook.Facebook",                                 # Facebook
    "4DF9E0F8.Netflix",                                  # Netflix
    "CAF9E577.Plex",                                     # Plex (vecchio pacchetto)
    "Plex.Plex",                                         # Plex (nuovo pacchetto)
    "Twitter.Twitter",                                   # Twitter
    "Instagram.Instagram",                               # Instagram
    "Snapchat.Snapchat",                                 # Snapchat
    "TikTok.TikTok",                                     # TikTok
    "Reddit.Reddit",                                     # Reddit

    # ===============================
    # Giochi preinstallati
    # ===============================
    "king.com.CandyCrushSaga",                           # Candy Crush Saga
    "king.com.CandyCrushSodaSaga",                       # Candy Crush Soda Saga
    "king.com.BubbleWitch3Saga",                         # Bubble Witch 3 Saga
    "Microsoft.MicrosoftSolitaireCollection",            # Microsoft Solitaire Collection

    # ===============================
    # Video / Audio
    # ===============================
    "Clipchamp.Clipchamp",                               # Clipchamp
    "SpotifyAB.SpotifyMusic",                            # Spotify
    "TuneIn.TuneInRadio",                                # TuneIn Radio
    "Microsoft.ZuneMusic",                               # Groove Music
    "Microsoft.ZuneVideo",                               # Film e TV
    "Microsoft.Zune",                                    # Zune legacy

    # ===============================
    # Microsoft Bing
    # ===============================
    "Microsoft.BingFinance",                             # Bing Finanza
    "Microsoft.BingNews",                                # Bing News
    "Microsoft.BingSports",                              # Bing Sport
    "Microsoft.BingTranslator",                          # Bing Traduttore
    "Microsoft.BingWeather",                             # Bing Meteo
    "Microsoft.BingWallpaper",                           # Bing Wallpaper
    "Microsoft.MakeBingYourSearchEngine",                # Imposta Bing come motore
    "Microsoft.BingFoodAndDrink",                        # Bing Cibo e Bevande
    "Microsoft.BingHealthAndFitness",                    # Bing Salute e Fitness
    "Microsoft.BingTravel",                              # Bing Viaggi

    # ===============================
    # Assistenti / AI
    # ===============================
    "Microsoft.Copilot",                                 # Microsoft Copilot
    "Microsoft.Cortana",                                 # Cortana (vecchio)
    "Microsoft.549981C3F5F10",                           # Cortana (nuovo ID)

    # ===============================
    # Office / Produttività
    # ===============================
    "Microsoft.OfficeHub",                               # Office Hub
    "Microsoft.Office.Launcher",                         # Office Launcher
    "Microsoft.Office.OneNote",                          # OneNote
    "Microsoft.Office.Outlook",                          # Outlook
    "Microsoft.OneConnect",                              # OneConnect
    "Microsoft.PowerAutomateDesktop",                    # Power Automate Desktop
    "Microsoft.Todos",                                   # Microsoft To Do (vecchio)
    "Microsoft.Todo",                                    # Microsoft To Do (nuovo)

    # ===============================
    # Utilità Microsoft
    # ===============================
    "MicrosoftCorporationII.QuickAssist",                # Assistenza rapida
    "Microsoft.Appconnector",                            # App Connector
    "Microsoft.GetHelp",                                 # Ottieni assistenza
    "Microsoft.Getstarted",                              # Guida introduttiva
    "Microsoft.Messaging",                               # Messaggi
    "Microsoft.People",                                  # Persone
    "Microsoft.Print3D",                                 # Print 3D
    "Microsoft.MixedReality.Portal",                     # Portale Realtà Mista
    "Microsoft.Microsoft3DViewer",                       # Visualizzatore 3D

    # ===============================
    # Dev / Sviluppo
    # ===============================
    "Microsoft.Windows.DevHome",                         # Dev Home
    "Microsoft.DevHome",                                 # Dev Home (alias)

    # ===============================
    # Grafica / Foto
    # ===============================
    "Microsoft.MSPaint",                                 # Paint (vecchio)
    "Microsoft.Paint",                                   # Paint (nuovo)
    "Microsoft.Windows.Photos",                          # Foto di Windows

    # ===============================
    # Comunicazione
    # ===============================
    "Microsoft.SkypeApp",                                # Skype
    "microsoft.windowscommunicationsapps",               # Posta e Calendario

    # ===============================
    # Sistema / Accessori
    # ===============================
    "Microsoft.WindowsAlarms",                           # Orologio
    "Microsoft.WindowsMaps",                             # Mappe
    "Microsoft.WindowsSoundRecorder",                    # Registratore vocale
    "Microsoft.WindowsFeedback",                         # Feedback Windows
    "Microsoft.WindowsFeedbackHub",                      # Hub di Feedback
    "Microsoft.YourPhone",                               # Collegamento al telefono
    "Microsoft.WindowsTerminal",                         # Terminale di Windows

    # ===============================
    # Xbox / Gaming
    # ===============================
    "Microsoft.XboxApp",                                 # Xbox App
    "Microsoft.GamingApp",                               # App Xbox Game Pass
    "Microsoft.XboxGameOverlay",                         # Xbox Game Overlay
    "Microsoft.XboxGamingOverlay",                       # Xbox Gaming Overlay
    "Microsoft.XboxIdentityProvider",                    # Xbox Identity Provider
    "Microsoft.XboxSpeechToTextOverlay",                 # Xbox Speech Overlay
    "Microsoft.Xbox.TCUI",                               # Xbox TCUI
    "Microsoft.GamingServices"                           # Gaming Services
)

# -----------------------------------
# Rimozione App per utenti attuali
# -----------------------------------
Write-Host "[*] Rimozione delle App preinstallate in corso..." -ForegroundColor Yellow

foreach ($App in $Bloatware) {
    Get-AppxPackage -Name $App -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# -----------------------------------
# Rimozione App Provisioned
# -----------------------------------
Write-Host "[*] Rimozione App Provisioned..." -ForegroundColor Yellow

$OfflineImage = "$env:SystemDrive\"

foreach ($App in $Bloatware) {

    $ProvPackages = Get-AppxProvisionedPackage -Online |
                    Where-Object { $_.DisplayName -like "$App*" }

    foreach ($Pkg in $ProvPackages) {
        try {
            Remove-AppxProvisionedPackage `
                -Path $OfflineImage `
                -PackageName $Pkg.PackageName `
                -ErrorAction Stop | Out-Null
        }
        catch {
            # Ignora pacchetti non removibili / stub
        }
    }
}

# ----------------
# Pulizia finale
# ----------------
Write-Host ""
Write-Host "=======================================" -ForegroundColor Green
Write-Host "   RIMOZIONE COMPLETATA CON SUCCESSO   " -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

Pause