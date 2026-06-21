function message-log() {
    param (
        [string] $message_input,
        [string] $message_type = "info",
        [string] $file_log = "C:\YSS\Logs\Script_Log_File.log"
    )

    if ($message_type -eq "info") {
        $message_prefix = "INFO - "
    }
    elseif ($message_type -eq "success") {
        $message_prefix = "SUCCESS - "
    }
    elseif ($message_type -eq "error") {
        $message_prefix = "ERROR - "
    }
    elseif ($message_type -eq "warning") {
        $message_prefix = "WARNING - "
    }
    $message_full = $message_prefix + $message_input

    Write-Output "$message_full"
    Write-Output "$message_full" >> "$file_log"
}



message-log -message-input "info message" -message_type "info"
message-log -message-input "info message"
message-log -message-input "success message" -message_type "success"
message-log -message-input "error message" -message_type "error"
message-log -message-input "warning message" -message_type "warning"
message-log -message-input "warning message" -message_type "warning" -file_log "C:\YSS\test\anywhere/log" 