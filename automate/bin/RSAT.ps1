<# 
Remote Server 

wusa https://support.microsoft.com/en-au/kb/934307
Remote Server Administration Tools for Windows 7 with Service Pack 1 (SP1)
https://www.microsoft.com/en-au/download/details.aspx?id=7887

#>

# $OperatingSystem = Get-WmiObject Win32_OperatingSystem
# Switch -regex ($OperatingSystem.Version)
$OperatingSystem = (Get-WmiObject -Class Win32_OperatingSystem).Caption
Switch -regex ($OperatingSystem)
{
    "Microsoft Windows 7 Enterprise" {
        %WINDIR%\system32\wusa.exe "$PSScriptRoot\Windows6.1-KB958830-x64-RefreshPkg.msu" /quiet /norestart /log:"C:\RSAT.log"
       dism /online /enable-feature /featurename:RemoteServerAdministrationTools
       dism /online /enable-feature /featurename:RemoteServerAdministrationTools-Roles
       dism /online /enable-feature /featurename:RemoteServerAdministrationTools-Roles-AD
       dism /online /enable-feature /featurename:RemoteServerAdministrationTools-Roles-AD-DS
       dism /online /enable-feature /featurename:RemoteServerAdministrationTools-Roles-AD-DS-Snapins
       dism /online /enable-feature /featurename:RemoteServerAdministrationTools-Roles-AD-Powershell
       dism /online /enable-feature /featurename:RemoteServerAdministrationTools-Roles-DHCP
       dism /online /enable-feature /featurename:RemoteServerAdministrationTools-Roles-DNS
    }
    "Microsoft Windows Server 2008 R2 Enterprise" {
        Import-Module ServerManager
        Add-WindowsFeature RSAT
    }
    "Microsoft Windows Server 2012" {
        Install-WindowsFeature RSAT
    }
    DEFAULT { Write-Host "Nothing to do." }
}