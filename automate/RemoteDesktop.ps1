<# 
Remote Desktop

DISM https://technet.microsoft.com/en-au/library/hh825236.aspx (local only)
Add-WindowsFeature https://msdn.microsoft.com/en-us/library/ee662309.aspx (remote installs too)
Install-WindowsFeature https://technet.microsoft.com/en-us/library/jj205467.aspx (replaces Add-WindowsFeature which is now an alias)

#>

$OperatingSystem = (Get-WmiObject -Class Win32_OperatingSystem).Caption
Switch -regex ($OperatingSystem)
{
    "Microsoft Windows Server 2003" {
        Write-Host "Nothing to do."
    }
    "Microsoft Windows 7 Enterprise" {
        Write-Host "Nothing to do."
    }
    "Microsoft Windows Server 2008 R2 Enterprise" {
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
        netsh advfirewall firewall set rule group="remote desktop" new enable=Yes
        }
    "Microsoft Windows Server 2012" {
        Set-NetFirewallRule -DisplayGroup "Remote Desktop" -Enabled True
    }
    DEFAULT { Write-Host "Nothing to do." }
}