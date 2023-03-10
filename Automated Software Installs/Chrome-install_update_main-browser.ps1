#this script will silently install and run chrome installer
function main(){
    function keyboard($key){
        [System.Windows.Forms.SendKeys]::SendWait("$key");
    }
    function default_browser(){
        $browser = get-itempropertyvalue "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice\" -name ProgId
        #here we go through and make this our default browser
        if ((systeminfo | Select-String "Microsoft Windows 10Default apps
                " -Quiet) -eq $true){
            keyboard '^{ESC}'; sleep 1
            keyboard '(choose a default web browser)'; sleep 1
            keyboard '{ENTER}'; sleep 1.5
            keyboard '{ENTER}'; sleep 1
            if ($browser -ne "ChromeHTML"){
                keyboard '{TAB}'; sleep 1           
                keyboard '{ENTER}'; sleep 1.5
                keyboard '{ESC}'; sleep 2
            }
            if ($browser -ne "ChromeHTML"){
                keyboard '^{ESC}'; sleep 1
                keyboard '(choose a default web browser)'; sleep 1
                keyboard '{ENTER}'; sleep 1.5
                keyboard '{ENTER}'; sleep 1
                keyboard '{ENTER}'; sleep 1
                keyboard '{ENTER}'; sleep 1
                keyboard '{ESC}'; sleep 1
            }
            if ($browser -ne "ChromeHTML"){
                keyboard '^{ESC}'; sleep 1
                keyboard '(choose a default web browser)'; sleep 1
                keyboard '{ENTER}'; sleep 1.5
                keyboard '{ENTER}'; sleep 1
                keyboard '{TAB}'; sleep 1          
                keyboard '{ENTER}'; sleep 1
                keyboard '{ENTER}'; sleep 1
                keyboard '{ENTER}'; sleep 1
                keyboard '{ESC}'; sleep 1
                }
            }
        elseif ((systeminfo | Select-String "Microsoft Windows 11" -Quiet) -eq $true){
            keyboard '^{ESC}'; sleep .75
            keyboard '(Default apps)'; sleep .75
            keyboard '{ENTER}'; sleep .75
            keyboard '{TAB}'; sleep .75
            keyboard '{TAB}'; sleep .75
            keyboard '{TAB}'; sleep .75
            keyboard '{TAB}'; sleep .75
            keyboard '(Chrome)'; sleep .75
            keyboard '{TAB}'; sleep .75
            keyboard '{ENTER}'; sleep .75
            keyboard '{ENTER}'; sleep .75
        }
        taskkill /IM SystemSettings.exe /F
        }
    function taskbar_pin($app){
        #Now we pin this to the taskbar
        keyboard '^{ESC}'; sleep .75
        keyboard "($app)"; sleep .75
        keyboard "(+{F10})"; sleep .75
        keyboard '{UP}'; sleep .75
        keyboard '{UP}'; sleep .75
        keyboard '{ENTER}'; sleep .75
        keyboard '{ESC}'
    }
    #here we define variables
    $ran_directory = $PWD
    $download_path = "$env:USERPROFILE\Downloads\"
    $installer_path = ($download_path + "chrome_installer.exe")
    $installer_exists = test-path $installer_path
    
    #here start running the download and install code
    cd $download_path
    if ($installer_exists){
        rm "chrome_installer.exe"
    }
    try{
        Invoke-WebRequest -Uri "https://ninite.com/chrome/ninite.exe" -OutFile $installer_path
        while (!(Test-Path "$installer_path")) {sleep 4.2}
        #write a for loop that checks te file-path to see if its there if it isnt rety do this for about 5 minutes igf hasnt installed exit and say there were issues, or try downloading it again , then say issues
    }
    catch{
        write-error "Error while downloading installer"
        exit
    }
    try{
        Start-Process -FilePath ".\chrome_installer.exe" -WindowStyle Hidden
        while (!(Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe")) {sleep 4.2}
        sleep 1.5
        taskkill /IM Ninite.exe /F
    }
    catch{
        write-error "Error while running installer"
        exit
    }
    Add-Type -AssemblyName System.Windows.Forms
    #here we go through and make this our default browser
    sleep 2
    default_browser
    taskbar_pin "google chrome"
    cd $ran_directory
}

main
