function process-monitornew() {
    param (
        [string] $process_name,
        [bool] $scan_only = $false,
        [string] $process_id_info_old
    )

    if ($scan_only -eq $true) {
        $process_id_info = (Get-Process | where-object {$_.ProcessName -like "*$process_name*"}).id
    }
    else {
        $process_id_info_new = (Get-Process | where-object {$_.ProcessName -like "*$process_name*"}).id
        
        $process_comparison = Compare-Object -ReferenceObject $process_id_info_old -DifferenceObject $process_id_info_new
        if ($process_comparison) {
            $process_id_info = ($process_comparison).InputObject
        }
        else {
            $process_id_info = $false

        }
    }
    return $process_id_info
}

$process_current = process-monitornew -process_name "msiexec" -scan_only $true
msiexec # start msiexec as example
process-monitornew -process_name "msiexec" -scan_only $false -process_id_info_old $process_current