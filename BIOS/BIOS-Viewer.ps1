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

Function Get_HP_BIOS_Settings() {
    $Script:Get_BIOS_Settings = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration -ErrorAction SilentlyContinue |  % { New-Object psobject -Property @{   
    Setting = $_."Name"
    Value = $_."currentvalue"
    Available_Values = $_."possiblevalues"
    }}  | select-object Setting, Value, possiblevalues
    $Get_BIOS_Settings
} #Tested and working

Function Get_Lenovo_BIOS_Settings() {
  $Script:Get_BIOS_Settings = gwmi -class Lenovo_BiosSetting -namespace root\wmi  | select-object currentsetting | Where-Object {$_.CurrentSetting -ne ""} |
  select-object @{label = "Setting"; expression = {$_.currentsetting.split(",")[0]}} ,
  @{label = "Value"; expression = {$_.currentsetting.split(",*;[")[1]}}
  $Get_BIOS_Settings
} #Tested and working

Function Get_Dell_BIOS_Settings() {
    function Dell_Dependancy {
        $Path = "$env:Temp\VcRedist"
        $Module = "VcRedist"
        $Repository = "PSGallery"

        If (!(Test-Path "$Path")) { #Checks to see if the directory is made if not makes it
            New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $null
        }
        Else {
            message-log "Directory already made"
        }
        If (!(Get-PSRepository -Name "$Repository")) { #Checks to see if the repository is set, if not sets it
           Set-PSRepository -Name "$Repository" -InstallationPolicy "Trusted"
        }
        Else {
            message-log "PSGallery already installed"
        }
        If (!(Get-Module -Name $Module -ListAvailable)) { #Checks to see if the module is installed, if not installs it
            install-Module -Name "$Module" -Force > $null
        }
        Else {
            message-log "Module already Installed"
        }

        #Installs Visual studio C++ modules
        $Redists = Get-VcList | Save-VcRedist -Path $Path | Install-VcRedist -Silent
        
        message-log "Installed Visual C++ Redistributables:"
        $Redists | Select-Object -Property "Name", "Release", "Architecture", "Version" -Unique
    }

    Set-ExecutionPolicy Unrestricted -Force
    try {
        If (!(Get-PackageProvider | Where-Object { $_.Name -like "NuGet" })){
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
            }
        Else {
            message-log "NuGet Already Installed"
        }
        
        $WarningPreference='silentlycontinue'
        
        If (!(Get-Module -ListAvailable -Name DellBIOSProvider)) {
            Install-Module -Name DellBIOSProvider -Force -Scope CurrentUser
        }
        Else {
            message-log "DellBIOSProvider already installed"
        }

        Import-Module -Name DellBIOSProvider -Force | out-null

        get-command -module DellBIOSProvider | out-null

        if (!(Test-Path "DellSmbios:\")) {
            message-log "Could not find required pathway `"DellSmbios:\`" after requirments and module`n`nThis is likely due to the machine\BIOS being to old." -message_type "error"
        }
        Else {               
            cd "DellSmbios:\UEFIvariables"
            
            set-item .\ForcedNetworkFlag 0 -ErrorAction SilentlyContinue 

            $Script:Get_BIOS_Settings = get-childitem -path DellSmbios:\ | select-object category |
            foreach {
                get-childitem -path @("DellSmbios:\" + $_.Category)  | select-object attribute, currentvalue
            }
            $Script:Get_BIOS_Settings = $Get_BIOS_Settings |  % { New-Object psobject -Property @{
                Setting = $_."attribute"
                Value = $_."currentvalue"
                }}  | select-object Setting, Value
            $Get_BIOS_Settings
            Set-ExecutionPolicy Default -Force
            Uninstall-Module -Name DellBIOSProvider -Force
        }
    }
    catch {
        Set-ExecutionPolicy Default -Force
        Uninstall-Module -Name DellBIOSProvider -Force
    }
} #Tested and working

$Manufacturer = (Get-WmiObject -Class Win32_ComputerSystem).Manufacturer

if ($Manufacturer -like "*Dell*") {
    Get_Dell_BIOS_Settings
}
elseif ($Manufacturer -like "*HP*") {
    Get_HP_BIOS_Settings
}
elseif ($Manufacturer -like "*Lenovo*") {
    Get_Lenovo_BIOS_Settings
}
else {
    message-log "Cant Detect the following`nManufacturer: $Manufacturer" -message_type "error"
}
