<# 
DNS

DISM https://technet.microsoft.com/en-au/library/hh825236.aspx (local only)
Add-WindowsFeature https://msdn.microsoft.com/en-us/library/ee662309.aspx (remote installs too)
Install-WindowsFeature https://technet.microsoft.com/en-us/library/jj205467.aspx (replaces Add-WindowsFeature which is now an alias)

#>

$OperatingSystem = (Get-WmiObject -Class Win32_OperatingSystem).Caption
Switch -regex ($OperatingSystem)
{
    "Microsoft Windows Server 2003" {
        dism /online /Enable-Feature /FeatureName:DNS-Server-Full-Role
        dism /online /Enable-Feature /FeatureName:DNS-Server-Tools
    }
    "Microsoft Windows 7 Enterprise" {
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools /FeatureName:RemoteServerAdministrationTools-Roles /FeatureName:RemoteServerAdministrationTools-Roles-DNS
    }
    "Microsoft Windows Server 2008 R2 Enterprise" {
        Import-Module ServerManager
        Add-WindowsFeature DNS
        Add-WindowsFeature RSAT-DNS-Server

        <# Configure

        dnscmd /ResetForwarders 8.8.8.8 /Slave

        #>
        }
    "Microsoft Windows Server 2012" {
        Install-WindowsFeature DNS -IncludeManagementTools
        # Install-WindowsFeature RSAT-DNS-Server

        <# Configure

            Add-DnsServerForwarder -IPAddress 8.8.8.8 -PassThru

        #>
    }
    DEFAULT { Write-Host "Nothing to do." }
}
