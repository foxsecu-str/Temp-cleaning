param (
    [switch]$Prod
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
    $Line | Tee-Object -FilePath $LogFile -Append
}

# ===============================
# Sécurité PROD
# ===============================
if ($Prod) {
    Write-Host "MODE PRODUCTION ACTIVÉ" -ForegroundColor Red
    $Confirm = Read-Host "Tapez NETTOYER pour continuer"
    if ($Confirm -ne "NETTOYER") {
        Write-Log "Exécution annulée par l'utilisateur"
        exit
    }
} else {
    Write-Host "Mode simulation actif (aucune suppression réelle)" -ForegroundColor Yellow
    Write-Log "Mode simulation"
}

# ===============================
# Fonctions
# ===============================
function Clean-Folder {
    param (
        [string]$Path,
        [string]$Label
    )

    Write-Log "Nettoyage : $Label ($Path)"

    if (!(Test-Path $Path)) {
        Write-Log "Chemin introuvable"
        return
    }

    if ($Prod) {
        Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Log "SIMULATION : fichiers listés mais non supprimés"
    }
}

# ===============================
# Nettoyages
# ===============================

Clean-Folder -Path $env:TEMP -Label "Temp utilisateur"
Clean-Folder -Path "C:\Windows\Temp" -Label "Temp système"

# Cache Windows Update
Write-Log "Nettoyage cache Windows Update"
if ($Prod) {
    Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
    Clean-Folder -Path "C:\Windows\SoftwareDistribution\Download" -Label "Windows Update"
    Start-Service wuauserv -ErrorAction SilentlyContinue
} else {
    Write-Log "SIMULATION : Windows Update"
}

# Delivery Optimization
Clean-Folder -Path "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache" `
             -Label "Delivery Optimization"

# Cache Microsoft Store
Clean-Folder -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsStore_*\LocalCache" `
             -Label "Microsoft Store"

# Cache DNS
Write-Log "Vidage cache DNS"
if ($Prod) {
    Clear-DnsClientCache
} else {
    Write-Log "SIMULATION : Clear-DnsClientCache"
}

# Corbeille
Write-Log "Vidage corbeille"
if ($Prod) {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
} else {
    Write-Log "SIMULATION : Clear-RecycleBin"
}

# ===============================
# Fin
# ===============================
Write-Log "Nettoyage terminé"
Write-Host "Terminé. Log : $LogFile" -ForegroundColor Cyan
