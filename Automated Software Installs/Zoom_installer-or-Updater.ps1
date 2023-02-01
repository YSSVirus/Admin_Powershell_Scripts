function main(){ #This is our main function for organization
	$ErrorActionPreference = "Stop"
	$Version_Powershell_Major = $PSVERSIONTABLE.PSVersion.Major
	function Error_Handling($text){
	$PSItem.ScriptStackTrace
	$PSItem.Exception.Message
	$ProgressPreference = 'SilentlyContinue'
	}
	function Removing_Old_Zoom(){ #This will uninstall any old Zoom version avoiding side by side issues
		$zip_path = "C:\temp_zoom\CleanZoom.zip"
		$exe_path = "C:\temp_zoom\CleanZoom.exe"
		$Zoom_Uninstaller = "https://support.zoom.us/hc/en-us/article_attachments/360084068792/CleanZoom.zip"
		$Zoom_Uninstaller_Path = "C:\temp_zoom\CleanZoom.zip"
		$command = "invoke-webrequest" + " -uri " + "$Zoom_Uninstaller" + " -OutFile " + "$zip_path"
		Try {
			Invoke-Expression -Command $command | Out-Null
			while (!(Test-Path $Zoom_Uninstaller_Path)) { Start-Sleep 1 }
		}#Downloading the uninstaller
		catch{
			$Error_Text = 'Could not download the un-installer for zoom'
			Error_Handling($Error_Text)
			exit
		}#error if it cant download un-installer
		Expand-Archive -Path "C:\temp_zoom\CleanZoom.zip" -DestinationPath "C:\temp_zoom\"
		Start-Process ".\CleanZoom.exe" -ArgumentList "/silent /keep_outlook_plugin /keep_lync_plugin /keep_notes_plugin" -wait
	}
	function Downloading_Zoom(){
		$Download_URL = "https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64"
		cd "C:\temp_zoom"
		$command = "invoke-webrequest" + " -uri " + "$Download_URL" + " -OutFile " + "C:\temp_zoom\ZoomInstaller.msi"
		Try { #Now we try running that with first chrome, then the default browser, then it will print the link out if nothing else works
			Invoke-Expression "$command"
			while (!(Test-Path "C:\temp_zoom\ZoomInstaller.msi")) { Start-Sleep 1 }
		}
		catch{
			$Error_Text = 'Could not download the installer for zoom'
			Error_Handling($Error_Text)
			exit
		}
		try{
			Start-Process "./ZoomInstaller.msi" -ArgumentList "/qn /passive /quiet" -Wait
		}
		catch{
			echo 'Zoom could not install'
		}
	}
	$checking = Test-Path "C:\temp_zoom\ZoomInstaller.msi" ###change
	$Start_Dir = $PWD
	$Download_Dir = "C:\temp_zoom\"
	cd $Download_Dir
	Try{
		$File_Checker = "C:\temp_zoom\ZoomInstaller.msi"
	}#testing to see if there is any old previously downloaded installers then removes them
	Catch{
		$File_Checker = 'NULL'
	}#This is mainly a placeholder in-case there is no old installer
	if ($checking){
		Removing_Old_Zoom
	}# this uninstalls the old version of zoom IF THE USER HAS IT
	Downloading_Zoom #Here we install zoom
	cd $Start_Dir
}

if ((Test-Path "C:\temp_zoom\") -eq $true){
	rm C:\temp_zoom -Recurse
}

$req = Invoke-WebRequest -uri "https://www.deepfreeze.com/Cloud/pr/softwareupdater/Latest" -UseBasicParsing
$req_content = $req.RawContent
$key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Zoom*"
if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Zoom*") -eq "$null"){
	$key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Zoom*"
	$installLocation = (Get-ItemProperty -Path $key -Name "DisplayVersion").DisplayVersion
	$zoom_version = $installLocation.Split(" ")[0]
}
else{
	$installLocation = (Get-ItemProperty -Path $key -Name "DisplayVersion").DisplayVersion
	$zoom_version = $installLocation.Split(" ")[0]
}
echo $zoom_version 
mkdir "C:\temp_zoom" | Out-Null
if (($req_content -NotContains "Zoom updated to $zoom_version") -or ($zoom_version -eq $null)){
	main #main
}
rm C:\temp_zoom -Recurse
exit #exit upon completion
