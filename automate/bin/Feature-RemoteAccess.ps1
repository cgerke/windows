<# 
Remote Access

DISM https://technet.microsoft.com/en-au/library/hh825236.aspx (local only)
Add-WindowsFeature https://msdn.microsoft.com/en-us/library/ee662309.aspx (remote installs too)
Install-WindowsFeature https://technet.microsoft.com/en-us/library/jj205467.aspx (replaces Add-WindowsFeature which is now an alias)

#>

$OperatingSystem = (Get-WmiObject -Class Win32_OperatingSystem).Caption
Switch -regex ($OperatingSystem)
{
    "Microsoft Windows Server 2003" {
        "https://technet.microsoft.com/en-au/library/hh825236.aspx"
        dism /online /NoRestart /Enable-Feature /FeatureName:RemoteAccess
        dism /online /NoRestart /Enable-Feature /FeatureName:RemoteAccessMgmtTools
        dism /online /NoRestart /Enable-Feature /FeatureName:RemoteAccessPowershell
        dism /online /NoRestart /Enable-Feature /FeatureName:RemoteAccessServer
        dism /online /NoRestart /Enable-Feature /FeatureName:RASRoutingProtocols
        dism /online /NoRestart /Enable-Feature /FeatureName:RASServerAdminTools
    }
    "Microsoft Windows 7 Enterprise" {
        Write-Host "Nothing to do."
    }
    "Microsoft Windows Server 2008 R2 Enterprise" {
        "https://msdn.microsoft.com/en-us/library/ee662309.aspx"
        Import-Module ServerManager
        Add-WindowsFeature NPAS-RRAS-Services
        Add-WindowsFeature NPAS-RRAS
        Add-WindowsFeature NPAS-Routing
        Add-WindowsFeature RSAT-NPAS
        }
    "Microsoft Windows Server 2012" {
        "https://technet.microsoft.com/en-us/library/jj205467.aspx"
        "(replaces Add-WindowsFeature which is now an alias)"
        Install-WindowsFeature RemoteAccess -IncludeManagementTools
        Install-WindowsFeature Routing -IncludeManagementTools
        #Install-WindowsFeature RSAT-RemoteAccess
        #Install-WindowsFeature RSAT-RemoteAccess-Mgmt
        #Install-WindowsFeature RSAT-RemoteAccess-PowerShell
    }
    DEFAULT { Write-Host "Nothing to do." }
}
