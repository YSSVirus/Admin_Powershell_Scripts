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
            Write-Host "Directory already made"
        }
        If (!(Get-PSRepository -Name "$Repository")) { #Checks to see if the repository is set, if not sets it
           Set-PSRepository -Name "$Repository" -InstallationPolicy "Trusted"
        }
        Else {
            Write-Host "PSGallery already installed"
        }
        If (!(Get-Module -Name $Module -ListAvailable)) { #Checks to see if the module is installed, if not installs it
            install-Module -Name "$Module" -Force > $null
        }
        Else {
            Write-Host "Module already Installed"
        }

        #Installs Visual studio C++ modules
        $Redists = Get-VcList | Save-VcRedist -Path $Path | Install-VcRedist -Silent
        
        Write-Host "Installed Visual C++ Redistributables:"
        $Redists | Select-Object -Property "Name", "Release", "Architecture", "Version" -Unique
    }

    Set-ExecutionPolicy Unrestricted -Force
    try {
        If (!(Get-PackageProvider | Where-Object { $_.Name -like "NuGet" })){
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
            }
        Else {
            echo "NuGet Already Installed"
        }
        
        $WarningPreference='silentlycontinue'
        
        If (!(Get-Module -ListAvailable -Name DellBIOSProvider)) {
            Install-Module -Name DellBIOSProvider -Force -Scope CurrentUser
        }
        Else {
            Write-Host "DellBIOSProvider already installed"
        }

        Import-Module -Name DellBIOSProvider -Force | out-null

        get-command -module DellBIOSProvider | out-null

        if (!(Test-Path "DellSmbios:\")) {
            Write-Error "Could not find required pathway `"DellSmbios:\`" after requirments and module`n`nThis is likely due to the machine\BIOS being to old."
        }
        Else {               
            cd "DellSmbios:\UEFIvariables"
            
            set-item .\ForcedNetworkFlag 0  

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
    Write-Error "Cant Detect the following`nManufacturer: $Manufacturer"
}
