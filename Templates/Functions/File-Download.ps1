function file_download() {
    param (
        [string] $file_url = "https://example.com",
        [string] $file_folder = "C:\yss\Example",
        [string] $file_name = "Example.exe"
    )

    # Pre Checks Variables
    ## Variable Assignment
    $file_location = $false
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy
    $web_client = New-Object System.Net.WebClient
    $web_client.Headers.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/138.0.0.0 Safari/537.36")
    $retry_count = 5
    $retry_delay_seconds = 3
    $timeout = 60
    $file_location = "$file_folder\$file_name"
    ## Verify Download Folder
    if (!(Test-Path $file_folder)) {
        ### Create Donwload folder if it doesnt exist
        New-Item -Path $file_folder -ItemType Directory -Force | Out-Null
    }



    # File Download
    try {
        ## Attempt Invoke web request
        Invoke-WebRequest -Uri $file_url -OutFile $file_location -TimeoutSec $timeout
    }
    catch {
        for ($i = 1; $i -le $retry_count; $i++) {
            try {
                ## Download Action
                $web_client.DownloadFile($file_url, $file_location)
                break
            } catch {
                if ($i -lt $retry_count) {
                    ## Attempt retry and output that it failed
                    Start-Sleep -Seconds $retry_delay_seconds
                }
                else {
                    $file_location = $false
                }
            }
        }

    }

    # Verify the file was created
    if ((Test-Path $file_location) -eq $false) {
        $file_location = $false
    }

    return "$file_location"
}



$file_download_path = file_download -file_url "https://example.com" -file_folder "C:\yss\Example" -file_name "Example.exe"