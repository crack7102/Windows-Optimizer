# =======================================================
#  ELIMINACIÓN DE APLICACIONES PREINSTALADAS EN WINDOWS
# =======================================================

# Control de privilegios de administrador
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator"))
{
    Write-Host "Reinicio el script como administrador..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Clear-Host
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ELIMINACIÓN DE LAS APLICACIONES PREINSTALADAS DE WINDOWS  " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# -----------------------------------
# Lista de aplicaciones de Microsoft que se deben eliminar
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
# Eliminación de aplicaciones para usuarios actuales
# -----------------------------------
Write-Host "[*] Eliminando las aplicaciones preinstaladas..." -ForegroundColor Yellow

foreach ($App in $Bloatware) {
    Get-AppxPackage -Name $App -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# -----------------------------------
# Eliminación de aplicaciones aprovisionadas
# -----------------------------------
Write-Host "[*] Eliminar aplicación aprovisionada..." -ForegroundColor Yellow

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
            # Ignorar paquetes no eliminables / stub
        }
    }
}

# ----------------
# Limpieza final
# ----------------
Write-Host ""
Write-Host "=======================================" -ForegroundColor Green
Write-Host "    ELIMINACIÓN COMPLETADA CON ÉXITO   " -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

Pause