function main(){ #This is our main function for organization
	$ErrorActionPreference = "Stop"
	$Version_Powershell_Major = $PSVERSIONTABLE.PSVersion.Major
	function Error_Handling($text){
	$PSItem.ScriptStackTrace
	$PSItem.Exception.Message
	$ProgressPreference = 'SilentlyContinue'
	}
	function Removing_Old_Zoom(){ #This will uninstall any old Zoom version avoiding side by side issues
		$zip_path = "C:\temp\CleanZoom.zip"
		$exe_path = "C:\temp\CleanZoom.exe"
		$Zoom_Uninstaller = "https://support.zoom.us/hc/en-us/article_attachments/360084068792/CleanZoom.zip"
		$Zoom_Uninstaller_Path = "C:\temp\CleanZoom.zip"
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
		Expand-Archive -Path "C:\temp\CleanZoom.zip" -DestinationPath "C:\temp\"
		Start-Process ".\CleanZoom.exe" -ArgumentList "/silent /keep_outlook_plugin /keep_lync_plugin /keep_notes_plugin" -wait
	}
	function Downloading_Zoom(){
		$Download_URL = "https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64"
		cd "C:\temp"
		$command = "invoke-webrequest" + " -uri " + "$Download_URL" + " -OutFile " + "C:\temp\ZoomInstaller.msi"
		Try { #Now we try running that with first chrome, then the default browser, then it will print the link out if nothing else works
			Invoke-Expression "$command"
			while (!(Test-Path "C:\temp\ZoomInstaller.msi")) { Start-Sleep 1 }
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
	$checking = Test-Path "C:\temp\ZoomInstaller.msi" ###change
	$Start_Dir = $PWD
	$Download_Dir = "C:\temp\"
	cd $Download_Dir
	Try{ 
		$File_Checker = "C:\temp\ZoomInstaller.msi"
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

if ((Test-Path "C:\temp\") -eq $true){
	rm C:\temp -Recurse
}

$req = Invoke-WebRequest -uri "https://www.deepfreeze.com/Cloud/pr/softwareupdater/Latest"
$req_content = $req.RawContent
$zoom = (Get-Package | Where-Object {$_.Name -like "*Zoom*"})
$zoom_version = $zoom.version
mkdir "C:\temp" | Out-Null
if (($req_content -Notmatch "$zoom_version") -or ($zoom_version -eq $null)){
	main #main
}
rm C:\temp -Recurse
#exit #exit upon completion
