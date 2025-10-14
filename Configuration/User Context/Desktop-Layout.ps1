<#
.SYNOPSIS
    Mirrors Desktop Layouts.

.DESCRIPTION
    This script is for mirroring desktops
    Allows you to export a current Desktop Configuration
    Allows you to import a custom Desktop Configuration
    Extensively logs each step

.PARAMETER get_desktop
    This will export the current desktops layout registry keys. 
    Example: -get_desktop

.PARAMETER apply_desktop
    This will use the exported files from -get_desktop to mirror the desktop.
    Example: -apply_desktop

.PARAMETER reg_key_location
    Location the registry keys will either apply from or export to. 
    Example: -reg_key_location C:\Reg_Files

.EXAMPLE
    .\Desktop-Layout.ps1
    This will export the current Desktop layout to the default export location
    Default Export Location: C:\Windows\Temp\Desktop-Layout_keys

.EXAMPLE
    .\Desktop-Layout.ps1 -apply_desktop
    This will Apply the exported Desktop Registry keys from the default import location
    Default Import Location: C:\Windows\Temp\Desktop-Layout_keys

.EXAMPLE
    .\Desktop-Layout.ps1 -apply_desktop -reg_key_location "C:\Reg_Files"
    This will Apply the exported Desktop Registry keys from the specified location
    Example Import Location: C:\Reg_Files

.NOTES
    Author: Aaron Bertsch
    Created: 2025-10-13
    Logs are saved to C:\Windows\Temp\Desktop-Layout.log
    Registry Key Default location is C:\Windows\Temp\Desktop-Layout_keys
#>



# Variables - User Supplied Parameters
param (
    [Parameter(Mandatory=$false)]
    [switch]$get_desktop,
    [Parameter(Mandatory=$false)]
    [switch]$apply_desktop,
    [Parameter(Mandatory=$false)]
    [string]$reg_key_location
)



# Variables - Static Script Variables
# Desktop Layout Registry Keys
$desktop_reg_keys = @(
  "HKCU\Software\Microsoft\Windows\Shell\Bags",
  "HKCU\Software\Microsoft\Windows\Shell\BagMRU"
)
#Error Log Info
$windows_temp = 'C:\Windows\Temp'
$log_file = "$windows_temp\Desktop-Layout.log"
New-Item -Path "$log_file" -ItemType File -Force



# Functions - Log Function
function log ($msg) {
    Write-Host $msg
    Add-Content -Path $log_file -Value $msg
    Start-Sleep -Seconds 2
}



# Logic - Are Required Variable Resolutions
# No Registry File Save Location Defined
if (-not ($reg_key_location)) {
    $reg_key_location = "$windows_temp\Desktop-Layout_keys"
    New-Item -Path "$reg_key_location" -ItemType Directory -Force
    log "No Location Applied`nDefaulting to get_desktop`nDefaulting Save Location to $reg_key_location"
}
# Avoid Conflicting Parameters
if ($apply_desktop -and $get_desktop) {
    $get_desktop = $true
    log "Conflicting Parameters, cant use get and apply Desktop at the same time`nDefaulting to get_desktop`nSave Location to $reg_key_location"
}
# No Action Parameters Defined
if ((-not ($get_desktop)) -and (-not ($apply_desktop)) ) {
    $get_desktop = $true
    log "No Get or Apply Action Selected`nDefaulting to get_desktop`nDefaulting Save Location to $reg_key_location"
}



# Logic - Applying Template or Taking Template
if ($get_desktop) {
    foreach ($reg_key in $desktop_reg_keys) {
        $name = ($reg_key -split '\\')[-1]
        try {
            reg export $reg_key "$reg_key_location\$name.reg" /y
            log "SUCCESS _  Exporting: $reg_key"
        }
        catch {
            log "FAILED _ Exporting -> $reg_key: $_"
        }
    }
}
elseif ($apply_desktop) {
    if (Test-Path $reg_key_location) {
        # Get all .reg files in that folder
        $regFiles = Get-ChildItem -Path $reg_key_location -Filter '*.reg' -File
        # Loop through and import the registry keys
        foreach ($file in $regFiles) {
            try {
                reg import $file.FullName
                log "SUCCESS _  Importing: $($file.Name)"
            }
            catch {
                log "FAILED _ Importing -> $($file.Name): $_"
            }
        }
    }
    else {
        log "FAILED _ Folder not found: $reg_key_location"
    }   
}
