# ==================================================
# Autopilot + Intune Cleanup
# PowerShell 7 / macOS Friendly
# ==================================================

Clear-Host

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      AUTOPILOT + INTUNE CLEANUP"
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# --------------------------------------------------
# Verify Required Modules
# --------------------------------------------------

$RequiredModules = @(
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.DeviceManagement",
    "WindowsAutoPilotIntune"
)

foreach ($Module in $RequiredModules) {

    if (-not (Get-Module -ListAvailable -Name $Module)) {

        Write-Host ""
        Write-Host "Missing module: $Module" -ForegroundColor Red
        Write-Host "Install the module and try again."
        Write-Host ""

        exit
    }
}

# --------------------------------------------------
# Connect to Microsoft Graph
# --------------------------------------------------

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow

Connect-MgGraph `
    -Scopes `
    "DeviceManagementManagedDevices.ReadWrite.All",
    "DeviceManagementServiceConfig.ReadWrite.All"

Write-Host "Connected." -ForegroundColor Green
Write-Host ""

# --------------------------------------------------
# File Paths
# --------------------------------------------------

$csvPath = "./serialNumbers.csv"
$logPath = "./cleanup-results.log"

if (!(Test-Path $csvPath)) {

    Write-Host ""
    Write-Host "serialNumbers.csv not found." -ForegroundColor Red
    Write-Host ""

    exit
}

# --------------------------------------------------
# Load Serial Numbers
# --------------------------------------------------

$SerialNumbers = Get-Content $csvPath |
    Where-Object { $_.Trim() -ne "" }

# --------------------------------------------------
# Initialize Counters
# --------------------------------------------------

$AutopilotRemoved = 0
$IntuneRemoved = 0
$NotFound = 0
$Failed = 0

# --------------------------------------------------
# Collect Device Inventory
# --------------------------------------------------

Write-Host "Collecting Autopilot inventory..." -ForegroundColor Yellow
$AutopilotDevices = Get-AutoPilotDevice

Write-Host "Collecting Intune inventory..." -ForegroundColor Yellow
$IntuneDevices = Get-MgDeviceManagementManagedDevice -All

# --------------------------------------------------
# Generate Summary Counts
# --------------------------------------------------

$AutopilotFound = 0
$IntuneFound = 0

foreach ($SN in $SerialNumbers) {

    if ($AutopilotDevices | Where-Object SerialNumber -eq $SN) {
        $AutopilotFound++
    }

    if ($IntuneDevices | Where-Object SerialNumber -eq $SN) {
        $IntuneFound++
    }
}

Write-Host ""
Write-Host "Deletion Summary"
Write-Host "--------------------------------------"
Write-Host "Autopilot Records Found : $AutopilotFound"
Write-Host "Intune Records Found    : $IntuneFound"
Write-Host ""

# --------------------------------------------------
# Process Devices
# --------------------------------------------------

foreach ($SerialNumber in $SerialNumbers) {

    $APDevice = $AutopilotDevices |
        Where-Object { $_.SerialNumber -eq $SerialNumber }

    $IntuneDevice = $IntuneDevices |
        Where-Object { $_.SerialNumber -eq $SerialNumber }

    if ($IntuneDevice) {
        $DeviceName = $IntuneDevice.DeviceName
    }
    elseif ($APDevice) {
        $DeviceName = "Autopilot Only"
    }
    else {
        $DeviceName = "Not Found"
    }

    Write-Host ""
    Write-Host "=================================================="
    Write-Host "Serial Number : $SerialNumber"
    Write-Host "Device Name   : $DeviceName"
    Write-Host "=================================================="

    # --------------------------------------------------
    # Remove Autopilot Device
    # --------------------------------------------------

    if ($APDevice) {

        try {

            Remove-AutopilotDevice $APDevice.Id -ErrorAction Stop

            Write-Host "✓ Autopilot removed" -ForegroundColor Green

            Add-Content $logPath "$SerialNumber - Autopilot Removed"

            $AutopilotRemoved++
        }
        catch {

            Write-Host "✗ Autopilot removal failed" -ForegroundColor Red

            Add-Content $logPath "$SerialNumber - Autopilot Removal Failed"

            $Failed++
        }
    }
    else {

        Write-Host "• Autopilot not found" -ForegroundColor Yellow
    }

    # --------------------------------------------------
    # Remove Intune Device
    # --------------------------------------------------

    if ($IntuneDevice) {

        try {

            Remove-MgDeviceManagementManagedDevice `
                -ManagedDeviceId $IntuneDevice.Id `
                -ErrorAction Stop

            Write-Host "✓ Intune removed" -ForegroundColor Green

            Add-Content $logPath "$SerialNumber - Intune Removed"

            $IntuneRemoved++
        }
        catch {

            Write-Host "✗ Intune removal failed" -ForegroundColor Red

            Add-Content $logPath "$SerialNumber - Intune Removal Failed"

            $Failed++
        }
    }
    else {

        Write-Host "• Intune not found" -ForegroundColor Yellow
    }

    # --------------------------------------------------
    # Neither Found
    # --------------------------------------------------

    if (!$APDevice -and !$IntuneDevice) {

        Add-Content $logPath "$SerialNumber - Not Found"

        $NotFound++
    }
}

# --------------------------------------------------
# Final Results
# --------------------------------------------------

Write-Host ""
Write-Host "=================================================="
Write-Host "FINAL RESULTS"
Write-Host "=================================================="
Write-Host ""

Write-Host ("Autopilot Removed : {0}" -f $AutopilotRemoved) -ForegroundColor Green
Write-Host ("Intune Removed    : {0}" -f $IntuneRemoved) -ForegroundColor Green
Write-Host ("Not Found         : {0}" -f $NotFound) -ForegroundColor Yellow
Write-Host ("Failed            : {0}" -f $Failed) -ForegroundColor Red

Write-Host ""
Write-Host "Cleanup Complete." -ForegroundColor Cyan
Write-Host ""