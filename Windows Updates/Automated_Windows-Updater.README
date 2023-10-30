This Windows update script will run through all updates that can be seen from the current point, this means that if there are updates behind updates it will not get these

If you are looking for something like this then there needs to be a user with no password during this and place a batch file to run this in the startup folder

Batch file Example:
@echo off

set "UpdateScriptPath=C:\Scripts\Deployment-Scripts\Install-WindowsUpdate.ps1"

PowerShell.exe -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -NoExit -File ""%UpdateScriptPath%""' -Verb RunAs"
