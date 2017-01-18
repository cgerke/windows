<# 
Active Directory

DISM https://technet.microsoft.com/en-au/library/hh825236.aspx (local only)
Add-WindowsFeature https://msdn.microsoft.com/en-us/library/ee662309.aspx (remote installs too)
Install-WindowsFeature https://technet.microsoft.com/en-us/library/jj205467.aspx (replaces Add-WindowsFeature which is now an alias)
dcpromo https://technet.microsoft.com/en-us/library/cc732887(v=ws.11).aspx
Install-ADDSForest https://technet.microsoft.com/en-us/library/hh974720(v=wps.630).aspx
Unattend https://support.microsoft.com/en-us/kb/947034

#>


Get-CimInstance win32_networkadapterconfiguration -filter "ipenabled = 'True'" -ComputerName $computername | 
Select PSComputername,
@{Name = "IPAddress";Expression = {
[regex]$rx ="(\d{1,3}(\.?)){4}"
$rx.matches($_.IPAddress).Value}},MACAddress

$IPAddress = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -ExpandProperty IPAddress
Write-Host $IPAddress

exit

$OperatingSystem = (Get-WmiObject -Class Win32_OperatingSystem).Caption
Switch -regex ($OperatingSystem)
{
    "Microsoft Windows 7 Enterprise" {
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools-ServerManager
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools-Roles 
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools-Roles-AD
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools-Roles-AD-DS
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools-Roles-AD-DS-SnapIns
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools-Roles-AD-DS-AdministrativeCenter
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools-Roles-AD-DS-NIS
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools-Roles-AD-LDS
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools-Roles-AD-Powershell
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools-Roles-DNS
    }
    "Microsoft Windows Server 2008 R2 Enterprise" {
        Import-Module ServerManager
        Add-WindowsFeature AD-Domain-Services
        Add-WindowsFeature RSAT-ADDS -IncludeAllSubFeature
        Add-WindowsFeature RSAT-DNS-Server
        dcpromo /unattend:"$PSScriptRoot\Feature-ActiveDirectory.txt"
            
        }
    "Microsoft Windows Server 2012" {
        "Windows 2012"
        Install-WindowsFeature AD-Domain-Services –IncludeManagementTools
        $SafeModeAdministratorPasswordText = 'TellEvery1!'
        $SafeModeAdministratorPassword = ConvertTo-SecureString -AsPlainText $SafeModeAdministratorPasswordText -Force
        Install-ADDSForest –DomainName cgerke.ddns.net –CreateDNSDelegation –DomainMode Win2008 -DomainNetbiosName "cgerke" –ForestMode Win2008R2 -InstallDns –DatabasePath "c:\NTDS" –SYSVOLPath "c:\SYSVOL" –LogPath "c:\LOGS" -SafeModeAdministratorPassword $SafeModeAdministratorPassword
    }
    DEFAULT { Write-Host "Nothing to do." }
}
