<#
.SYNOPSIS
    Renames the local or remote Windows computer and optionally restarts it.

.DESCRIPTION
    This script renames a computer to a new hostname. 
    It can rename the local machine or a remote machine if provided.
    It handles local or domain machines and can prompt for credentials if needed.

.PARAMETER name_new
    The new hostname for the computer. 
    If not provided, the script will prompt for it.

.PARAMETER name_old
    The current hostname of the computer you want to rename.
    It will try to use current credentials by default, if that doesnt work it will prompt you 
    If not provided, the script will use the local hostname.

.PARAMETER reboot
    Switch to force a reboot after renaming the computer. 
    Example: -reboot

.EXAMPLE
    .\Rename-Computer.ps1 -name_new "NEWPC" -reboot
    Renames the local computer to NEWPC and restarts it.

.EXAMPLE
    .\Rename-Computer.ps1
    Prompts the user to enter the new hostname and renames the local computer without rebooting.

.EXAMPLE
    .\Rename-Computer.ps1 -name_new "NEWPC" -name_old "OLDPC" -reboot
    Renames the Remote Computer to NEWPC and restarts it (If were unable to with current user credentials, it will prompt you for them.

.NOTES
    Author: Aaron Bertsch
    Created: 2025-10-13
    Logs are saved to C:\Windows\Temp\System-Rename.log
#>




# Input using variables
param (

    # Mandatory Variable - New Machine Name
    [Parameter(Mandatory=$false)]
    [string]$name_new,

    # Optional Variable - Old Machine Name 
    [Parameter(Mandatory=$false)]
    [string]$name_old,

    # Optional Variable - Force Reboot
    [Parameter(Mandatory=$false)]
    [switch]$reboot = $false
)
if (-not ($name_new) ) {
    $name_new = Read-Host "Enter the New Hostname for the computer"
}



#Error Log Info
$log_file = 'C:\Windows\Temp\System-Rename.log'
New-Item -Path "$log_file" -ItemType File -Force



# Error Information
function error_report($rename_type, $errorObject, $name_new, $log_file) {

    # Display FAIL Information, then delay for readability
    Write-Error "FAILED _ $rename_type rename failed, could not rename the machine to $name_new (Log Info: $log_file)" -ForegroundColor Red
    Write-Error "Error details: $($errorObject.Exception.Message)"
    Start-Sleep -Seconds 10

    # Log Error Information in file
    Add-Content -Path "$log_file" -Content "$($errorObject.Exception.Message)"

    # Exit with an FAIL
    exit 1
}



# Success Information
function success_report($rename_type, $name_new, $log_file) {

    # Display SUCCESS Information, then delay shortly for readibility if needed
    $success_message = "SUCCESS _ $rename_type rename was successful, the machine has been renamed to $name_new (Log Info: $log_file)" -ForegroundColor Green
    Write-Host "$success_message"
    Start-Sleep -Seconds 3

    # Log Success Information in file
    Add-Content -Path "$log_file" -Content "$success_message"

    # Exit with a SUCCESS
    exit 0
}



function rename_computer($computer, $newName, $reboot, $log_file, $rename_type) {

    function rename_process($rename_type, $computer, $newName, $cred, $reboot) {
        if ($rename_type -eq "Domain Machine") {
            Rename-Computer -ComputerName $computer -NewName $newName -DomainCredential $cred -Confirm:$true -Restart:$reboot -Force
        }
        elseif ($rename_type -eq "Local Machine") {
            Rename-Computer -ComputerName $computer -NewName $newName -LocalCredential $cred -Confirm:$true -Restart:$reboot -Force
        }
    }

    try {
        # Rename With Running Credentials
        Rename-Computer -ComputerName $computer -NewName $newName -Confirm:$true -Restart:$reboot -Force
        Add-Content -Path $log_file -Value "Credentials - Running User"
        success_report $rename_type $newName $log_file
    }
    catch {

        # Prompt for Username and Password if using Local Machine or domain if running as same credentials fails 
        if ($rename_type -ne "None") {
            Add-Content -Path $log_file -Value "FAILED _ Credentials - Running User"
            # Fallback credential
            $user = Read-Host "Enter username for $computer"
            $password = Read-Host "Enter password" -AsSecureString
            $cred = New-Object System.Management.Automation.PSCredential ($user, $password)
            Add-Content -Path $log_file -Value "Credentials - Typed User -> $user"
            try {
                # Rename With New Credentials
                rename_process "$rename_type" "$computer" "$newName" $cred $reboot
                success_report $rename_type $newName $log_file
            }
            catch {
                # Error Log
                error_report $rename_type $_ $newName $log_file
            }
        }
        # Error Log
        error_report $rename_type $_ $newName $log_file
    }
}



# Query WMI for domain info
$os = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $name_old

if (-not ($name_old) ) {
    $rename_type = "Same Machine"
    $name_old = (hostname)
}
elseif ($os.PartOfDomain -eq $true) {
    $rename_type = "Domain Machine"
}
elseif ($os.PartOfDomain -eq $false) {
    $rename_type = "Local Machine"
}

$computer_old_name = "$name_old"
rename_computer "$computer_old_name" "$name_new" $reboot "$log_file" "$rename_type"



# Fallback Error Catch

# Log Error Information in file
Write-Error "Unhandled Exception (Log Info: $log_file)" -ForegroundColor Red
Start-Sleep -Seconds 10

# Log and Exit with Error
Add-Content -Path "$log_file" -Content "Unhandled Exception"

exit 1
