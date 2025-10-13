function main(){ # our main function for house keeping
	function Error_Handling($text){	 #Here we handle any and all errors, we also make them easir to read, track down and diagnose
		$PSItem.ScriptStackTrace
		$PSItem.Exception.Message
		Write-Host "$text" -ForegroundColor Red
	}
	function Powershell7_installer(){
		Try { 
			winget install --id "Microsoft.Powershell" --source winget -h | Out-Null 
			
		} #Here we try to install powershell 7
		Catch {
			$Error_Text = 'Could not install Powershell 7'
			Error_Handling($Error_Text)
			exit
		} #If install of Powershell 7 didnt work then we error out and give error info
	}
	
	$File_Checker = Test-Path "C:\\Program Files\\PowerShell\\7\\pwsh.exe"

	Try {
		winget -v | out-null
	} # Here we check whether or not the user has winget 
	Catch {
		Try	 
		{
			Install-Module -Name WingetTools -Confirm:$false -Force
			Install-WinGet -Confirm:$false
		}
		Catch #Error if we cant install winget
		{
			$Error_Text = 'Could not install winget'
			Error_Handling($Error_Text)
			exit
		}

	}#Install winget if user doesnt have it		
	if (!($File_Checker)){ 
		Powershell7_installer
	}#This checks if the user doesnt have the powershell 7 executable, if not it installs it
}

main # our main function for house keeping
