function main(){ #This is our main function for organization
	$ErrorActionPreference = "Stop"
	$Version_Powershell_Major = $PSVERSIONTABLE.PSVersion.Major
	function Error_Handling($text){
	$PSItem.ScriptStackTrace
	$PSItem.Exception.Message
	$ProgressPreference = 'SilentlyContinue'
	}
	function Removing_Old_Zoom(){ #This will uninstall any old Zoom version avoiding side by side issues
		$zip_path = "$home/Downloads/CleanZoom.zip"
		$exe_path = "$home/Downloads/CleanZoom.exe"
		if ((test-path $zip_path) -eq $true){
			rm $zip_path
		}#remove incase old zoom cleaner is out of date
		if ((test-path $exe_path) -eq $true){
			rm $exe_path
		}
		$Zoom_Uninstaller = "https://support.zoom.us/hc/en-us/article_attachments/360084068792/CleanZoom.zip"
		$Zoom_Uninstaller_Path = "$home\Downloads\CleanZoom.zip"
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
		Expand-Archive -Path "$home/Downloads/CleanZoom.zip" -DestinationPath "$home/Downloads/"
		Start-Process ".\CleanZoom.exe" -ArgumentList "/silent /keep_outlook_plugin /keep_lync_plugin /keep_notes_plugin" -wait
	}
	function Downloading_Zoom(){
		$Download_URL = "https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64"
		cd "$home/Downloads"
		$command = "invoke-webrequest" + " -uri " + "$Download_URL" + " -OutFile " + "$home/Downloads/ZoomInstaller.msi"
		Try { #Now we try running that with first chrome, then the default browser, then it will print the link out if nothing else works
			Invoke-Expression "$command"
			while (!(Test-Path "$home/Downloads/ZoomInstaller.msi")) { Start-Sleep 1 }
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
	function House_Cleaning(){
		rm "$home\Downloads\CleanZoom.zip"
		rm "$home\Downloads\cleanzoom.log"
		rm "$home\Downloads\ZoomInstaller.msi"
	}#cleans up old files

	$checking = Test-Path "$home/Downloads/ZoomInstaller.msi" ###change
	$Start_Dir = $PWD
	$Download_Dir = "$home/Downloads/"
	cd $Download_Dir
	Try{ 
		$File_Checker = "$home/Downloads/ZoomInstaller.msi"
		rm $File_Checker
	}#testing to see if there is any old previously downloaded installers then removes them
	Catch{ 
		$File_Checker = 'NULL'
	}#This is mainly a placeholder in-case there is no old installer
	if ($checking){
		Removing_Old_Zoom
	}# this uninstalls the old version of zoom IF THE USER HAS IT
	Downloading_Zoom #Here we install zoom
	House_Cleaning
	cd $Start_Dir

}

if (!($req -match "$version") -or ((Get-Package -Name "Zoom*" -EA Ignore) -eq $null)){
	main #main
}
exit #exit upon completion
