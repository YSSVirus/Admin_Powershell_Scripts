param (
    [bool] attempt_install_machine_wide = $true
)

function message-log() {
    param (
        [string] $message_input,
        [string] $message_type = "info",
        [string] $file_log = "C:\YSS\Logs\Install-Zoom.log"
    )

    if ($message_type -eq "info") {
        $message_prefix = "INFO - "
    }
    elseif ($message_type -eq "success") {
        $message_prefix = "SUCCESS - "
    }
    elseif ($message_type -eq "error") {
        $message_prefix = "ERROR - "
    }
    elseif ($message_type -eq "warning") {
        $message_prefix = "WARNING - "
    }
    $message_full = $message_prefix + $message_input

    Write-Output "$message_full"
    Write-Output "$message_full" >> "$file_log"
}

function folder_yss_verify() {
    param (
        [bool]$exit_on_error = $true
    )
    $folder_yss = "C:\YSS"

    if (!(Test-Path $folder_yss)) {
        New-Item -Path "$folder_yss" -ItemType Directory -Force | Out-Null

        if ((!(Test-Path $folder_yss)) -and ($exit_on_error -eq $true)) {
            exit 1
        }
    }
}

function admin-check {
    if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $user_role_admin = $true
    }
    else {
        $user_role_admin = $false
    }

    return $user_role_admin
}

function file_download() {
    param (
        [string] $file_url = "https://example.com",
        [string] $file_folder = "C:\yss\Example",
        [string] $file_name = "Example.exe"
    )

    # Pre Checks Variables
    ## Variable Assignment
    $file_location = $false
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy
    $web_client = New-Object System.Net.WebClient
    $web_client.Headers.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/138.0.0.0 Safari/537.36")
    $retry_count = 5
    $retry_delay_seconds = 3
    $timeout = 60
    $file_location = "$file_folder\$file_name"
    ## Verify Download Folder
    if (!(Test-Path $file_folder)) {
        ### Create Donwload folder if it doesnt exist
        New-Item -Path $file_folder -ItemType Directory -Force | Out-Null
    }



    # File Download
    try {
        ## Attempt Invoke web request
        Invoke-WebRequest -Uri $file_url -OutFile $file_location -TimeoutSec $timeout
    }
    catch {
        for ($i = 1; $i -le $retry_count; $i++) {
            try {
                ## Download Action
                $web_client.DownloadFile($file_url, $file_location)
                break
            } catch {
                if ($i -lt $retry_count) {
                    ## Attempt retry and output that it failed
                    Start-Sleep -Seconds $retry_delay_seconds
                }
                else {
                    $file_location = $false
                }
            }
        }

    }

    # Verify the file was created
    if ((Test-Path $file_location) -eq $false) {
        $file_location = $false
    }

    return "$file_location"
}

function process-monitornew() {
    param (
        [string] $process_name,
        [bool] $scan_only = $false,
        [string] $process_id_info_old
    )

    if ($scan_only -eq $true) {
        $process_id_info = (Get-Process | where-object {$_.ProcessName -like "*$process_name*"}).id
    }
    else {
        $process_id_info_new = (Get-Process | where-object {$_.ProcessName -like "*$process_name*"}).id
        
        $process_comparison = Compare-Object -ReferenceObject $process_id_info_old -DifferenceObject $process_id_info_new
        if ($process_comparison) {
            $process_id_info = ($process_comparison).InputObject
        }
        else {
            $process_id_info = $false

        }
    }
    return $process_id_info
}

function process-monitorend() {
    param (
        [int] $process_id,
        [int] $max_minutes = 5,
        [int] $check_interval_seconds = 10
    )

    $max_seconds = $max_minutes * 60
    $check_count = $max_seconds / $check_interval_seconds

    $counter = 0
    while(Get-Process -id $process_id -ErrorAction SilentlyContinue) {
        $counter = $counter + 1
        Start-Sleep -Seconds 5
        if ($counter -eq $check_count) {
            $process_exited = $false
        }
        else {
            $process_exited = $true
        }
    }
    return $process_exited
}

function install-verify {
    param (
        [string] $application,
        [int] $delay_check_seconds = 20
    )

    $application_installed = $false
    $application_version = $false

    Start-Sleep -seconds $delay_check_seconds
    
    # Current User Install Locations
    if ((Test-Path "HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") -and (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "*$application*" })) {
        $application_installed = $true
        $application_version = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "*$application*" }).DisplayVersion
    }
    if ((Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") -and (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "*$application*" })) {
        $application_installed = $true
        $application_version = (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "*$application*" }).DisplayVersion
    }
    # Current Machine Install Locations
    if ((Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") -and (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "*$application*" })) {
        $application_installed = $true
        $application_version = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "*$application*" }).DisplayVersion
    }
    if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") -and (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "*$application*" })) {
        $application_installed = $true
        $application_version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "*$application*" }).DisplayVersion
    }
    if (Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*$application*"}) {
        $application_installed = $true
        $application_version = (Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*$application*"}).Version
    }


    return $application_installed, $application_version
}



# Setup and Testing
folder_yss_verify -exit_on_error $true

if ((Test-Path "C:\YSS\Logs\Install-Zoom.log") -eq $true) {
    Remove-Item "C:\YSS\Logs\Install-Zoom.log" -Force
}

$application_installed, application_version = install-verify "Zoom"

if ($application_installed -eq $true) {
    message-log "Zoom is already installed - Exiting" -message_type "error"
    exit 0 
}
else {
    message-log "Zoom is not installed, continuing"
}

$user_role_admin = admin-check

if ($user_role_admin -and $attempt_install_machine_wide) {
    $installer_url = "https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64"
}
else {
    $installer_url = "https://zoom.us/client/latest/ZoomInstallerFull.exe?archType=x64"
}

# Download
$file_download_path = file_download -file_url "$installer_url" -file_folder "C:\YSS\Installers" -file_name "Zoom.msi"

if ($file_download_path -eq $false) {
    
}
elseif ((Test-Path "$file_download_path") -eq $true) {
    message-log "Zoom downloaded"
}
else {
    message-log "Zoom installer could not be detected after attempted download (Location: $file_download_path)" -message_type "error"
    exit 1
}

# Install
$process_current_list = process-monitornew -process_name "msiexec" -scan_only $true
msiexec /i "$file_download_path" /quiet
$process_current_id = process-monitornew -process_name "msiexec" -scan_only $false -process_id_info_old $process_current_list

if ($process_current_id -eq $false) {
    message-log "Installer couldnt be found running. exiting" -message_type "error"
    exit 1
}
else {
    message-log "Installer Started"
}

process-monitorend -process_id "$process_current_id" --max_minutes 15 --check_interval_seconds 5

if ($process_current_id -eq $false) {
    message-log "Installer never ended. exiting" -message_type "error"
    exit 1
}
else {
    message-log "Installer Ended"
}

# Cleanup and Verification
if ((Test-Path $file_download_path) -eq $true) {
    Remove-Item "$file_download_path" -Force | Out-Null
}

$application_installed, application_version = install-verify "Zoom"

if ($application_installed -eq $true) {
    message-log "Zoom is installed (Version: $application_version)" -message_type "success"
    exit 0 
}
else {
    message-log "Zoom could not be detected after attempted install" -message_type "error"
    exit 1
}
