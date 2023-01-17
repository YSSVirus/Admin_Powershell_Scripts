param([Parameter(Mandatory=$true)]$user,$password)
function main{
    if ($password){
        net user $user $password /add
    }
    net user $user /add
}

main $user $password
