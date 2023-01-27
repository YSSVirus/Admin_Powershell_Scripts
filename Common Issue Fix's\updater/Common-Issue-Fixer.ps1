param([switch] $restart)
function main(){
	$sfc = sfc /scannow
	$sfc = (($sfc) -replace "`0" | where {$_})
	$sfc_error = ($sfc | select-string "w" -Quiet)
	$dism = dism /Online /Cleanup-Image /RestoreHealth
	if (Test-Path "C:\common-issue-fixer.log" -eq $true){
		rm "C:\common-issue-fixer.log"
	}
	if (!($sfc_error)){
		Write-Output "SFC has detected problems, we recommend a restart after this script if not triggered"
	}
	if (!($dism | select-string "completed successfully")){
		Write-Output "dism has had errors completing"
	}
	$temp_profile_check = get-childitem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name | Select-String "(.*)(\.bak)$"
	$extra_check = Test-Path "C:\Users\temp"
	if ($temp_profile_check -and ($extra_check -eq $true)){
		Write-Host "Temp profile detected, the following all have signs of being temp profiles $temp_profile_check"
	}
	Get-EventLog -LogName System -EntryType Error,Warning
	if ($sfc_error){
		echo y|chkdsk c: /f /r /x
	}
}

main | Out-File -FilePath "C:\common-issue-fixer.log"
if ($restart.IsPresent){
	shutdown -r -t 0
}