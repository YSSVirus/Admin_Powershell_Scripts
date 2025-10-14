<#
.SYNOPSIS
    Enables or Disables USB Storage.

.DESCRIPTION
    This script can control whether or not USB Storage is able to be used
    Enable USB Storage
    Disable USB Storage

.PARAMETER disable
    This will DISABLE usb Storage on the machine

.PARAMETER enable
    This will ENABLE usb Storage on the machine

.EXAMPLE
    .\Control-usbStorage.ps1 -disable
    Disables usb Storage on the machine

.EXAMPLE
    .\Control-usbStorage.ps1 enable
    Enables usb Storage on the machine

.NOTES
    Author: Aaron Bertsch
    Created: 2025-10-13
    Logs are saved to C:\Windows\Temp\Control-usbStorage.log
#>



# Input using variables
param (

    # Disable USB Storage
    [Parameter(Mandatory=$false)]
    [switch]$disable,

    # Enable USB Storage
    [Parameter(Mandatory=$false)]
    [switch]$enable
)



#Error Log Info
$windows_temp = 'C:\Windows\Temp'
$log_file = "$windows_temp\Control-usbStorage.log"
New-Item -Path "$log_file" -ItemType File -Force



# Functions - Log Function
function log ($msg) {
    Write-Host $msg
    Add-Content -Path $log_file -Value $msg
    Start-Sleep -Seconds 2
}
# Functions - USB Storage Control
function control_usb_storage ([int]$status) {
    Set-item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR" -Name "Start" -Value $status -Force
}



# Ensure script runs as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    log "ERROR _ This script must be run as Administrator!"
    exit
}



# Logic - Verify input variables
if ($enable -and $disable) {
    log "ERROR _ You can't choose enable and disable at the same time"
    exit
}
if ( (-not ($enable)) -and (-not ($disable)) ) {
    log "No option chosen, nothing has changed"
}



# Log Current Key Value
$usbStartValue = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR" -Name "Start").Start
log "Current Status _ Registry key is currently set to the value of $usbStartValue"



# Logic - Disable or Enable
if ($enable) {
    try {
        control_usb_storage 3
        log "SUCCESS _ USB Storage has been ENABLED"
        # Restart File Explorer to apply
        log "Restarting Explorer..."
        Stop-Process -Name explorer -Force
        Start-Process explorer.exe
        log "Explorer restarted."
    }
    catch {
        log "ERROR _ We got an error while enabling the usb device`n$_"
    }
}
elseif ($disable) {
    try {
        control_usb_storage 4
        log "SUCCESS _ USB Storage has been DISABLED"
        # Restart File Explorer to apply
        log "Restarting Explorer..."
        Stop-Process -Name explorer -Force
        Start-Process explorer.exe
        log "Explorer restarted."
    }
    catch {
        log "ERROR _ We got an error while disabling the usb device`n$_"
    }
}
else {
    log "ERROR _ We have encounterd an error where we could quite determine enable or disable, nothing has been changed"
}
