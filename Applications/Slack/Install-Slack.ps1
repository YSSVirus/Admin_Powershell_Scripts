param (
    [bool] $attempt_install_machine_wide = $true # This will attempt a machine wide installation, however if the user doesnt have permissions it falls back to a per user install, you can also toggle it with this option
)

function message-log() {
    param (
        [string] $message_input,
        [string] $message_type = "info",
        [string] $file_log = "C:\YSS\Logs\Install-Slack.log"
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

    # if already exists
    if ((Test-Path $file_location) -eq $true) {
        Remove-item "$file_location" -Force
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
            }
        }

    }

    return $file_location
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

if ((Test-Path "C:\YSS\Logs\Install-Slack.log") -eq $true) {
    Remove-Item "C:\YSS\Logs\Install-Slack.log" -Force -ErrorAction SilentlyContinue
}

$application_installed, $application_version = install-verify "Slack"

if ($application_installed -eq $true) {
    message-log "Slack is already installed - Exiting" -message_type "error"
    exit 0 
}
else {
    message-log "Slack is not installed, continuing"
}

$user_role_admin = admin-check

$installer_url = "https://slack.com/downloads/instructions/windows?ddl=1&build=win64_msix"
$installer_name = "slack.msix"

# Download
$file_download_path = file_download -file_url "$installer_url" -file_folder "C:\YSS\Installers" -file_name "$installer_name"

if ((Test-Path $file_download_path) -eq $false) {
    message-log "Slack installer could not be detected after attempted download (Location: $file_download_path) (Installer url: $installer_url)" -message_type "error"
    exit 1
}
else {
    message-log "Slack downloaded"
}

# Install
if ($user_role_admin -and $attempt_install_machine_wide) {
    Add-AppxProvisionedPackage -Online -PackagePath "$file_download_path" -SkipLicense -Regions "all"
}
else {
    Add-AppxPackage -Path "$file_download_path"
}

# Cleanup and Verification
if ((Test-Path $file_download_path) -eq $true) {
    Remove-Item "$file_download_path" -Force | Out-Null
}

$application_installed, $application_version = install-verify "Slack"

if ($application_installed -eq $true) {
    message-log "Slack is installed (Version: $application_version)" -message_type "success"
    exit 0 
}
else {
    message-log "Slack could not be detected after attempted install" -message_type "error"
    exit 1
}