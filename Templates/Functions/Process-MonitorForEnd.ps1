function process-monitorend() {
    param (
        [int] $process_id,
        [int] $max_minutes = 5,
        [int] $check_interval_seconds = 10
    )

    $max_seconds = $max_minutes * 60
    $check_count = $max_seconds / $check_interval_seconds

    $counter = 0
    while(Get-Process -id $process_id -ErrorAction SilentlyContinue) {
        $counter = $counter + 1
        Start-Sleep -Seconds 5
        if ($counter -eq $check_count) {
            $process_exited = $false
        }
        else {
            $process_exited = $true
        }
    }
    return $process_exited
}

process-monitorend -process_id "19444"
process-monitorend -process_id "19444" --max_minutes 15
process-monitorend -process_id "19444" --check_interval_seconds 5
process-monitorend -process_id "19444" --max_minutes 15 --check_interval_seconds 5