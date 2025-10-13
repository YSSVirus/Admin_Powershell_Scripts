$auto_Update_folder = "C:\Auto_Update"
$DeploymentScripts = "$auto_Update_folder\Deployment-Scripts"
$DeploymentFlags = "$auto_Update_folder\Deployment-Flags"
$Deployment_Log = "$auto_Update_folder\AutoUpdate.log"

New-Item -Path "$auto_Update_folder" -ItemType Directory -Force
New-Item -Path "$DeploymentScripts" -ItemType Directory -Force
New-Item -Path "$DeploymentFlags" -ItemType Directory -Force
New-Item -Path "$Deployment_Log" -ItemType File -Force

$host.UI.RawUI.WindowTitle = "Windows Updates"

Set-ExecutionPolicy Unrestricted -Force

Stop-Service -Name winmgmt -Force
winmgmt /resetrepository
Start-Service -Name winmgmt
Update-MpSignature

If (!(Get-PackageProvider | Where-Object { $_.Name -like "NuGet" })){
	Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
}
Else {
	echo "NuGet Already Installed"
}
If (!(Get-module -ListAvailable | Where-Object { $_.Name -like "PSWindowsUpdate" })){
	Install-Module PSWindowsUpdate -Force
}
Else {
	echo "PSWindowsUpdate Already Installed"
}

Import-Module PSWindowsUpdate
$Update = Get-WindowsUpdate
Install-WindowsUpdate -AcceptAll -AutoReboot

if (!(Test-Path "C:\Auto_Update\AutoUpdate.log")) {
    Write-Host "Windows Auto Update Log:`n`n" > "$Deployment_Log"
}
if (!($Update -eq $NULL)) {
	Write-Host "$Update" >> "C:\Auto_Update\AutoUpdate.log"
    Write-Host 'Restart-Computer -Force' >> "$Deployment_Log"
    Restart-Computer -Force
}
