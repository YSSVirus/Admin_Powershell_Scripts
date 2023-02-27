param(
    [Parameter(Mandatory=$false)]
    [string]$Username, #This is the username parameter that is not required, script checks if either -FullName or -UserName is used
    [Parameter(Mandatory=$false)]
    [string]$FullName, #This is the FullName parameter that is not required, script checks if either -FullName or -UserName is used
    [Parameter(Mandatory=$true)]
    [string]$NewPass #This is the NewPass parameter where you specify the AD users new password
)#These are the Parameters for the script

function main($Username,$NewPass,$FullName){
    if (-not (Get-Module -Name ActiveDirectory)) {
        Add-WindowsFeature RSAT-AD-PowerShell #Adding the needed features
    }#This checks if ad module is installed if not it installs it
    Import-Module ActiveDirectory #Importing the needed module
    
    function reset-password($Username,$NewPass){
        $newPasswordSecureString = ConvertTo-SecureString $NewPass -AsPlainText -Force #This converts the password to a secure string for the command
        #$passwordMeetsRequirements = Test-PasswordQuality -Password $NewPass #This checks if the password meets requirements
        #if (-not $passwordMeetsRequirements) {
        #    Write-Error "The password does not meet the domain password requirements." #This informs the user it didnt meet password requirements
        #    exit #This exits the script as there was an error
        #} # This informs user that the password didnt meet security requirements then exits
        Set-ADAccountPassword -Identity $Username -NewPassword $newPasswordSecureString -Reset #This resets the users password
        Write-Host "Password reset for user $($Username.samAccountName)" #lets the user know they have reset the password to the users account
    }#This function is where the users password reset actually happens

    if($NewPass -eq $null){
        if (($Username -eq $null) -and ($FullName -eq $null)){
            Write-Error "You need to specify a password aswell as a User-name using -Username paramater1 or a users Full Name using -FullName parameter" #This lets the user know that they need to specify the new password parameter and either a fullname parameter or a username parameter
            exit #This exits the script as there was an error
        } #This checks if they applied a username or full name paramater
        Write-Error "You Need to specify a new password with the -NewPass" #This tells the user to add the new password paramater only
        exit #This exits the script as there was an error
    } #This tests whether there is a new password specified or not
    elseif ($Username) {
        reset-password $Username $NewPass #This is where it calls the reset password function with the username and password
    } #This checks if the user specified a UserName
    elseif ($FullName) {
        $FirstName,$LastName = $FullName.Split(" ") #This splits the full name into 2 variables, it splits at the space, assigns first segment to firstname and the second segment to lastname
        $user = Get-ADUser -Filter {(GivenName -eq $FirstName) -and (Surname -eq $LastName)} #This gets the users account using first and lastname
        if ($user.Count -gt 1) {
            Write-Error "Multiple user accounts found with name '$FirstName $LastName'" #This informs the user that there is more then one account with this name
            exit #This exits the script as there was an error
        } #This checks if the last command got more then one user and errors if it did
        $Username = $user.SamAccountName #This gets the username of the account
        reset-password $Username $NewPass #This calls the password reset with the newly aquired username
    } #This checks if the user specified a FullName 
    else {
        Write-Error "You must specify either a Username with the -Username parameter or a FullName with the -FullName Paramater" #This lets the user know they need to specify a username or a fullname
        exit #This exits the script as there was an error
    } #This is where the script errors if theres a password but no UserName or FullName specified
} #This is the main function that houses all the scripts code with the needed parameters

main $Username $NewPass $FullName #Calling our main function with the needed parameters
