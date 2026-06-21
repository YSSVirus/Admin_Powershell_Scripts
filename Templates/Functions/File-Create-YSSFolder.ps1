function folder_yss_verify() {
    param (
        [bool]$exit_on_error = $true
    )
    $folder_yss = "C:\YSS"

    if (!(Test-Path $folder_yss)) {
        New-Item -Path "$folder_yss" -ItemType Directory -Force | Out-Null

        if ((!(Test-Path $folder_yss)) -and ($exit_on_error -eq $true)) {
            exit 1
        }
    }
}



folder_yss_verify -exit_on_error $true