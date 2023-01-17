param ($user,[Parameter(Mandatory=$true)]$password)
function main{
    if (-not $user) #this triggers if there is no user defined
    {
        $user = (Get-CimInstance -ClassName Win32_ComputerSystem).Username #this allows us to bypass the admin user and see the current user under it
        $user = $user -replace ".*\\"
    }
    net user $user $password
}

main $user $password
