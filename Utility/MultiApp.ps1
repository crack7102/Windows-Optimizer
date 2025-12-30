# ==================================================
#              INSTALLATORE MULTI APP
# ==================================================

# -----------------------------------
# Controllo privilegi amministratore
# -----------------------------------
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator"))
{
    Write-Host "Rilancio lo script come amministratore..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# ----------------------------
# Funzione installazione app
# ----------------------------
Function Install-App {
    param($AppID, $AppName)
    Write-Host "`nInstallazione di $AppName in corso..."
    winget install $AppID -e
    Write-Host "Installazione di $AppName completata.`n"
    Start-Sleep 1
}

# ----------------------------------
# Categorie e sottocategorie con app
# ----------------------------------
$AppCategories = @{

    "Browser" = @{
        1 = @{Name="Brave Browser"; ID="Brave.Brave"}
        2 = @{Name="Google Chrome"; ID="Google.Chrome"}
        3 = @{Name="Microsoft Edge"; ID="Microsoft.Edge"}
        4 = @{Name="Mozilla Firefox ESR"; ID="Mozilla.Firefox.ESR.it"}
        5 = @{Name="Opera Browser"; ID="Opera.Opera"}
        6 = @{Name="SeaMonkey"; ID="Mozilla.SeaMonkey"}
        7 = @{Name="Tor Browser"; ID="TorProject.TorBrowser"}
		8 = @{Name="Vivaldi"; ID="Vivaldi.Vivaldi"}
        9 = @{Name="Zen Browser"; ID="Zen-Team.Zen-Browser"}
    }

    "Compressione e Archiviazione" = @{
        1 = @{Name="7-Zip"; ID="7zip.7zip"}
        2 = @{Name="PeaZip"; ID="Giorgiotani.Peazip"}
        3 = @{Name="WinRAR"; ID="RARLab.WinRAR"}
    }

    "Comunicazione e Chat" = @{
        1 = @{Name="Discord"; ID="Discord.Discord"}
        2 = @{Name="Microsoft Teams"; ID="Microsoft.Teams"}
        3 = @{Name="Telegram Desktop"; ID="Telegram.TelegramDesktop"}
        4 = @{Name="WhatsApp Desktop"; ID="9NKSQGP7F2NH"}
		5 = @{Name="Zoom"; ID="Zoom.Zoom"}
		6 = @{Name="Mozilla Thunderbird ESR"; ID="Mozilla.Thunderbird.ESR.it"}
    }

    "Controllo Remoto" = @{
        1 = @{Name="AnyDesk"; ID="AnyDesk.AnyDesk"}
        2 = @{Name="TeamViewer"; ID="TeamViewer.TeamViewer"}
    }

    "Grafica e Multimedia" = @{
        "Editing Fotografico" = @{
            1 = @{Name="Krita"; ID="KDE.Krita"}
            2 = @{Name="GIMP"; ID="GIMP.GIMP.3"}
            3 = @{Name="Inkscape"; ID="Inkscape.Inkscape"}
            4 = @{Name="Paint.NET"; ID="dotPDN.PaintDotNet"}
            5 = @{Name="IrfanView"; ID=@("IrfanSkiljan.IrfanView","IrfanSkiljan.IrfanView.PlugIns")}
        }
        "Editing Video e Audio" = @{
            1 = @{Name="Audacity"; ID="Audacity.Audacity"}
            2 = @{Name="OBS Studio"; ID="OBSProject.OBSStudio"}
            3 = @{Name="OpenShot"; ID="OpenShot.OpenShot"}
            4 = @{Name="Shotcut"; ID="Meltytech.Shotcut"}
			5 = @{Name="VSDC Video Editor"; ID="VSDC.Editor"}
        }
        "Audio Tagger" = @{
            1 = @{Name="Mp3tag"; ID="FlorianHeidenreich.Mp3tag"}
            2 = @{Name="MusicBrainz Picard"; ID="MusicBrainz.Picard"}
        }
        "Lettori Multimediali" = @{
            1 = @{Name="VLC Media Player"; ID="VideoLAN.VLC"}
            2 = @{Name="PotPlayer"; ID="Daum.PotPlayer"}
			3 = @{Name="K-Lite Mega Codec Pack"; ID="CodecGuide.K-LiteCodecPack.Mega"}
        }
        "Streaming" = @{
            1 = @{Name="Spotify"; ID="Spotify.Spotify"}
			2 = @{Name="Amazon Music"; ID="Amazon.Music"}
            3 = @{Name="iTunes"; ID="Apple.iTunes"}
        }
    }
    "Game Launcher" = @{
        1 = @{Name="GOG Galaxy"; ID="GOG.Galaxy"}
		2 = @{Name="Epic Games Launcher"; ID="EpicGames.EpicGamesLauncher"}
		3 = @{Name="EA App"; ID="ElectronicArts.EADesktop"}
		4 = @{Name="Steam"; ID="Valve.Steam"}
		5 = @{Name="Ubisoft Connect"; ID="Ubisoft.Connect"}
		6 = @{Name="Minecraft Launcher"; ID="Mojang.MinecraftLauncher"}
        7 = @{Name="Heroic Games Launcher"; ID="HeroicGamesLauncher.HeroicGamesLauncher"}
    }
	
    "Ufficio" = @{
        "PDF Reader" = @{
            1 = @{Name="Adobe Acrobat Reader"; ID="Adobe.Acrobat.Reader.64-bit"}
            2 = @{Name="PDF24 Creator"; ID="geeksoftwareGmbH.PDF24Creator"}
            3 = @{Name="SumatraPDF"; ID="SumatraPDF.SumatraPDF"}
			4 = @{Name="Okular"; ID="KDE.Okular"}
        }
        "Suite Completa" = @{
            1 = @{Name="LibreOffice"; ID="TheDocumentFoundation.LibreOffice"}
            2 = @{Name="Apache OpenOffice"; ID="Apache.OpenOffice"}
            3 = @{Name="OnlyOffice Desktop Editors"; ID="ONLYOFFICE.DesktopEditors"}
			4 = @{Name="SoftMaker FreeOffice 2024"; ID="SoftMaker.FreeOffice.2024"}
        }
    }

    "Sicurezza" = @{
        "Antivirus" = @{
            1 = @{Name="Avast Free Antivirus"; ID="XPDNZJFNCR1B07"}
            2 = @{Name="AVG Free Antivirus"; ID="XP8BX2DWV7TF50"}
            3 = @{Name="Avira Security"; ID="XPFD23M0L795KD"}
            4 = @{Name="Malwarebytes"; ID="Malwarebytes.Malwarebytes"}
            5 = @{Name="BitDefender"; ID="Bitdefender.Bitdefender"}
        }
        "Gestione Password" = @{
            1 = @{Name="KeePass"; ID="DominikReichl.KeePass"}
			2 = @{Name="QtPass"; ID="IJHack.QtPass"}
        }
    }

    "Sviluppo" = @{
        1 = @{Name="Atom"; ID="GitHub.Atom"}
		2 = @{Name="Notepad++"; ID="Notepad++.Notepad++"}
        3 = @{Name="Visual Studio Code"; ID="Microsoft.VisualStudioCode"}
		4 = @{Name="VSCodium"; ID="VSCodium.VSCodium"}
    }

    "Utility e Strumenti Vari" = @{
        "Utility di Sistema" = @{
            1 = @{Name="PowerToys"; ID="Microsoft.PowerToys"}
			2 = @{Name="CPU-Z"; ID="CPUID.CPU-Z"}
			3 = @{Name="GPU-Z"; ID="TechPowerUp.GPU-Z"}
        }
		"Uninstaller" = @{
            1 = @{Name="Bulk Crap Uninstaller"; ID="Klocman.BulkCrapUninstaller"}
			2 = @{Name="HiBit Uninstaller"; ID="HiBitSoftware.HiBitUninstaller"}
			3 = @{Name="IObit Uninstaller"; ID="IObit.Uninstaller"}
			4 = @{Name="Geek Uninstaller"; ID="GeekUninstaller.GeekUninstaller"}
        }
        "Masterizzazione" = @{
            1 = @{Name="ImgBurn"; ID="LIGHTNINGUK.ImgBurn"}
	        2 = @{Name="InfraRecorder "; ID="ChristianKindahl.InfraRecorder"}
        }
        "Supporti Avviabili" = @{
            1 = @{Name="Rufus"; ID="Rufus.Rufus"}
			2 = @{Name="Ventoy"; ID="Ventoy.Ventoy"}
			3 = @{Name="balenaEtcher"; ID="Balena.Etcher"}
        }
    }

    "Torrent e P2P" = @{
        1 = @{Name="FrostWire"; ID="FrostWire.FrostWire"}
        2 = @{Name="qBittorrent"; ID="qBittorrent.qBittorrent"}
        3 = @{Name="JDownloader"; ID="AppWork.JDownloader"}
        4 = @{Name="Transmission"; ID="Transmission.Transmission"}
    }

}

# --------------------------------------------
# Funzione menu categoria con sottocategorie
# --------------------------------------------
Function Show-CategoryMenu {
    param($CategoryName, $Apps)

    while ($true) {
        Clear-Host
        Write-Host "==== $CategoryName ====" -ForegroundColor Green

        # Separiamo sottocategorie e app singole
        $subCategories = @{}
        $singleApps = @{}

        foreach ($key in $Apps.Keys) {
            if ($Apps[$key].ContainsKey("ID")) {
                $singleApps[$key] = $Apps[$key]
            } else {
                $subCategories[$key] = $Apps[$key]
            }
        }

        # Mostra sottocategorie
        $i = 1
        $subMap = @{}
        foreach ($sub in ($subCategories.Keys | Sort-Object)) {
            Write-Host "$i) $sub"
            $subMap[$i] = $sub
            $i++
        }

        # Mostra app singole
        $j = $i
        $appMap = @{}
        foreach ($key in ($singleApps.Keys | Sort-Object)) {
            $entry = $singleApps[$key]
            Write-Host "$j) $($entry["Name"])"
            $appMap[$j] = $entry
            $j++
        }

        Write-Host "0) Torna al menu precedente"
        Write-Host "`n"
        $selInput = Read-Host "Seleziona opzione"
        $selIndex = 0
        if ([int]::TryParse($selInput, [ref]$selIndex)) {
            if ($selIndex -eq 0) { break }
            elseif ($subMap.ContainsKey($selIndex)) {
                Show-CategoryMenu $subMap[$selIndex] $Apps[$subMap[$selIndex]]
            } 
            elseif ($appMap.ContainsKey($selIndex)) {
                Install-App -AppID $appMap[$selIndex]["ID"] -AppName $appMap[$selIndex]["Name"]
            } 
            else {
                Write-Host "Selezione non valida." -ForegroundColor Red
                Start-Sleep 1
            }
        } else {
            Write-Host "Input non valido." -ForegroundColor Red
            Start-Sleep 1
        }
    }
}

# ================================
#         MENU PRINCIPALE
# ================================
while ($true) {
    Clear-Host

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "         INSTALLATORE MULTI APP         " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "`n       ==== MENU PRINCIPALE ===="      
    Write-Host "`n"

    $catIndex = 1
    $catMap = @{}
    foreach ($category in $AppCategories.Keys) {
        Write-Host "$catIndex) $category"
        $catMap[$catIndex] = $category
        $catIndex++
    }
    Write-Host "0) Esci"
    Write-Host "`n"
    $mainSelection = Read-Host "Seleziona una categoria"
    $selIndex = 0
    if ([int]::TryParse($mainSelection, [ref]$selIndex)) {
        if ($selIndex -eq 0) { break }
        if ($catMap.ContainsKey($selIndex)) {
            $categoryName = $catMap[$selIndex]
            Show-CategoryMenu $categoryName $AppCategories[$categoryName]
        } else {
            Write-Host "Selezione non valida." -ForegroundColor Red
            Start-Sleep 1.5
        }
    } else {
        Write-Host "Input non valido. Inserisci un numero." -ForegroundColor Red
        Start-Sleep 1.5
    }
}

Write-Host "`nUscita completata."