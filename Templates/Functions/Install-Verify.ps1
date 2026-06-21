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



$application_installed, application_version = install-verify -application "VirtualBox"
$application_installed, application_version = install-verify -application "VirtualBox" -delay_check_seconds 30