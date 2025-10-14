$ErrorActionPreference = "Stop"
$Version_Powershell_Major = $PSVERSIONTABLE.PSVersion.Major
function Error_Handling($text){
$PSItem.ScriptStackTrace
$PSItem.Exception.Message
$ProgressPreference = 'SilentlyContinue'
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