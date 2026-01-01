param (
    [switch]$Prod,
    [switch]$Silent
)

# ===============================
# Configuration
# ===============================
$LogDir = "C:\Temp"
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

$LogFile = "$LogDir\Win11_CacheCleanup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
    param ([string]$Message)
    $Line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    $Line | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

Write-Log "===== DÉBUT NETTOYAGE ====="
Write-Log "Mode PROD : $Prod | Mode Silent : $Silent"
Write-Log "Utilisateur : $env:USERNAME"

# ===============================
# Sécurité interactive (désactivée si Silent)
# ===============================
if ($Prod -and -not $Silent) {
    Write-Host "MODE PRODUCTION" -ForegroundColor Red
    $Confirm = Read-Host "Tapez NETTOYER pour continuer"
    if ($Confirm -ne "NETTOYER") {
        Write-Log "Annulé par l'utilisateur"
        exit 0
    }
}

if (-not $Prod) {
    Write-Log "MODE SIMULATION ACTIF"
}

# ===============================
# Fonctions
# ===============================
function Clean-Folder {
    param (
        [string]$Path,
        [string]$Label
    )

    Write-Log "Nettoyage : $Label | $Path"

    if (!(Test-Path $Path)) {
        Write-Log "Chemin introuvable"
        return
    }

    if ($Prod) {
        Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Suppression effectuée"
    } else {
        Write-Log "SIMULATION"
    }
}

# ===============================
# Nettoyages
# ===============================
Clean-Folder -Path $env:TEMP -Label "Temp utilisateur"
Clean-Folder -Path "C:\Windows\Temp" -Label "Temp système"

# Windows Update
Write-Log "Cache Windows Update"
if ($Prod) {
    Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
    Clean-Folder -Path "C:\Windows\SoftwareDistribution\Download" -Label "Windows Update"
    Start-Service wuauserv -ErrorAction SilentlyContinue
} else {
    Write-Log "SIMULATION Windows Update"
}

# Delivery Optimization
Clean-Folder -Path "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache" `
             -Label "Delivery Optimization"

# Microsoft Store
Clean-Folder -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsStore_*\LocalCache" `
             -Label "Microsoft Store"

# DNS
Write-Log "Cache DNS"
if ($Prod) {
    Clear-DnsClientCache
    Write-Log "DNS vidé"
} else {
    Write-Log "SIMULATION DNS"
}

# Corbeille
Write-Log "Corbeille"
if ($Prod) {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Log "Corbeille vidée"
} else {
    Write-Log "SIMULATION corbeille"
}

Write-Log "===== FIN NETTOYAGE ====="
exit 0
