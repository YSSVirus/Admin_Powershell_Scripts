
#
#   YSS - Aaron
#   Script: Invoke-LoggedInUserProcess.ps1
#   Purpose: Run a command in the active logged-in user session
#   Date: 2026-04-16
#   Compatible: PowerShell 5.1, 7+
#
 
function Invoke-LoggedInUserProcess {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Command,
 
        [string] $WorkingDirectory = "C:\YSS",
 
        [int] $TimeoutSeconds = 120,
 
        [switch] $WaitForExit
    )
 
    $token       = [IntPtr]::Zero
    $processInfo = $null
 
    try {
        if (-not ("YSS.NativeMethods" -as [type])) {
            Add-Type @"
using System;
using System.Runtime.InteropServices;
namespace YSS {
    public static class NativeMethods {
        [StructLayout(LayoutKind.Sequential)]
        public struct STARTUPINFO {
            public int cb; public string lpReserved; public string lpDesktop;
            public string lpTitle; public int dwX; public int dwY;
            public int dwXSize; public int dwYSize; public int dwXCountChars;
            public int dwYCountChars; public int dwFillAttribute;
            public int dwFlags; public short wShowWindow;
        }
        [StructLayout(LayoutKind.Sequential)]
        public struct PROCESS_INFORMATION {
            public IntPtr hProcess; public IntPtr hThread;
            public int dwProcessId; public int dwThreadId;
        }
        [DllImport("kernel32.dll")] public static extern uint WTSGetActiveConsoleSessionId();
        [DllImport("Wtsapi32.dll")] public static extern bool WTSQueryUserToken(uint id, out IntPtr token);
        [DllImport("advapi32.dll", SetLastError=true)]
        public static extern bool CreateProcessAsUser(
            IntPtr token, string app, string cmd,
            IntPtr p1, IntPtr p2, bool inherit,
            uint flags, IntPtr env, string dir,
            ref STARTUPINFO si, out PROCESS_INFORMATION pi);
        [DllImport("kernel32.dll")] public static extern uint WaitForSingleObject(IntPtr h, uint ms);
        [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr h);
    }
}
"@
        }
 
        $sessionId = [YSS.NativeMethods]::WTSGetActiveConsoleSessionId()
        if ($sessionId -eq 0xFFFFFFFF) {
            Write-Error "ERROR - No active console session found"
            return $false
        }
 
        if (-not [YSS.NativeMethods]::WTSQueryUserToken($sessionId, [ref]$token)) {
            Write-Error "ERROR - Failed to query user token for session $sessionId"
            return $false
        }
 
        $startup         = New-Object YSS.NativeMethods+STARTUPINFO
        $startup.cb      = [Runtime.InteropServices.Marshal]::SizeOf($startup)
        $startup.lpDesktop = "winsta0\default"
 
        $processInfo = New-Object YSS.NativeMethods+PROCESS_INFORMATION
 
        # Wrap in cmd.exe so shell operators (>, |, etc.) work as expected
        $exe     = "$env:SystemRoot\System32\cmd.exe"
        $cmdLine = "cmd.exe /c $Command"
 
        $created = [YSS.NativeMethods]::CreateProcessAsUser(
            $token,
            $exe,
            $cmdLine,
            [IntPtr]::Zero,
            [IntPtr]::Zero,
            $false,
            0x08000000,   # CREATE_NO_WINDOW
            [IntPtr]::Zero,
            $WorkingDirectory,
            [ref]$startup,
            [ref]$processInfo
        )
 
        if (-not $created) {
            $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
            Write-Error "ERROR - CreateProcessAsUser failed (Win32 error $err)"
            return $false
        }
 
        if ($WaitForExit) {
            $waitResult = [YSS.NativeMethods]::WaitForSingleObject(
                $processInfo.hProcess,
                $TimeoutSeconds * 1000
            )
 
            if ($waitResult -eq 0x102) {
                Write-Error "ERROR - Process timed out after $TimeoutSeconds seconds"
                return $false
            }
        }
 
        Write-Output "SUCCESS - Process launched (PID $($processInfo.dwProcessId))"
        return $true
    }
    catch {
        Write-Error "ERROR - $($_.Exception.Message)"
        return $false
    }
    finally {
        if ($processInfo) {
            if ($processInfo.hThread  -ne [IntPtr]::Zero) { [YSS.NativeMethods]::CloseHandle($processInfo.hThread)  | Out-Null }
            if ($processInfo.hProcess -ne [IntPtr]::Zero) { [YSS.NativeMethods]::CloseHandle($processInfo.hProcess) | Out-Null }
        }
        if ($token -ne [IntPtr]::Zero) { [YSS.NativeMethods]::CloseHandle($token) | Out-Null }
    }
}
 
 
 
Invoke-LoggedInUserProcess -Command 'whoami > C:\YSS\Temp\whoami.txt' -WaitForExit