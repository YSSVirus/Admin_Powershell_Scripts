function main(){ #This is our main function for organization
	$ErrorActionPreference = "Stop"	 
	$Version_Powershell_Major = $PSVERSIONTABLE.PSVersion.Major
	function Error_Handling($text){
	$PSItem.ScriptStackTrace
	$PSItem.Exception.Message
	Write-Host "$text" -ForegroundColor Red
}
	function Removing_Old_Zoom(){ #This will uninstall any old Zoom version avoiding side by side issues
		$Old_Zoom = "$home\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Zoom\"
		cd $Old_Zoom
		try{
			$Zoom_Uninstall_Command = "$home\AppData\Roaming\Zoom\uninstall\Installer.exe /uninstall"
			Start-Process -NoNewWindow Powershell.exe "-Command $Zoom_Uninstall_Command" -Wait
		}
		catch{
			$Error_Text = 'Could not locate Zoom uninstaller'
			Error_Handling($Error_Text)
			exit
		}
	}
	function Downloading_Zoom(){
		$Download_URL = "https://ninite.com/zoom/ninite.exe"
		$path = "$home/Downloads/"
		$path = $path + "Ninite Zoom Installer.exe"
		cd "$home/Downloads"
		Try { #Now we try running that with first chrome, then the default browser, then it will print the link out if nothing else works
			Start-Process -NoNewWindow -Wait invoke-webrequest -uri "$Download_URL" -Wait
			while (!(Test-Path $path)) { Start-Sleep 1 }
		}
		catch{
			try{
				#Start-Process -NoNewWindow -Wait "$Download_URL"
				while (!(Test-Path $path)) { Start-Sleep 1 }
			}
			catch{
				$Error_Text = 'Could not download the installer for zoom'
				Error_Handling($Error_Text)
				exit
			}
		}
		try{
			Start-Process -Wait '.\Ninite Zoom Installer.exe'
		}
		catch{
			echo 'Zoom could not install'
		}
	}
	$checking = Test-Path "$home\\AppData\\Roaming\\Zoom\\uninstall\\Installer.exe"
	Try{
		$File_Checker = Get-Item "$home\\Downloads\\ZoomInstaller.exe"
		rm $File_Checker
	}
	Catch{
		$File_Checker = 'NULL'
	}
	try{
		if ($checking){
			Removing_Old_Zoom 
		}
	}
	catch{
		Write-Host "No Zoom installed installing now"
	}
	cd "$home\Downloads\"
	Downloading_Zoom
}
main #main 
exit #exit upon completion
