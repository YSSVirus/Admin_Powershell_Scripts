# Script Variables
$ChromeInstallURL = "https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi"
$webClient = New-Object System.Net.WebClient
$retryCount = 3
$retryDelaySeconds = 2

$ChromeInstallerLocation = "$InstallerLocation\Chrome.msi"
$chromeInstalled = (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object { $_.DisplayName -like 'Google Chrome*' })



if ($chromeInstalled) {
    Write-Host "Google Chrome is already installed."
}
else {

    for ($i = 1; $i -le $retryCount; $i++) {
        try {
            $webClient.DownloadFile($ChromeInstallURL, $ChromeInstallerLocation)
            break
        } catch {
            Write-Output "Error: $_`nRetrying in $retryDelaySeconds seconds..."
            Start-Sleep -Seconds $retryDelaySeconds
        }
    }

    msiexec.exe /i "$ChromeInstallerLocation"

    Write-Host "Chrome is now Installed"
}