<# 
Remote Server 

wusa https://support.microsoft.com/en-au/kb/934307
Remote Server Administration Tools for Windows 7 with Service Pack 1 (SP1)
https://www.microsoft.com/en-au/download/details.aspx?id=7887

#>

$OperatingSystem = (Get-WmiObject -Class Win32_OperatingSystem).Caption
Switch -regex ($OperatingSystem)
{
    "Microsoft Windows 7 Enterprise" {
        "Windows 7"
        %WINDIR%\system32\wusa.exe "$PSScriptRoot\Windows6.1-KB958830-x64-RefreshPkg.msu" /quiet /norestart /log:"C:\RSAT.log"
    }
    DEFAULT { Write-Host "Nothing to do." }
}
