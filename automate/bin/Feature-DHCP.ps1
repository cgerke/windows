<# 
DHCP

DISM https://technet.microsoft.com/en-au/library/hh825236.aspx (local only)
Add-WindowsFeature https://msdn.microsoft.com/en-us/library/ee662309.aspx (remote installs too)
Install-WindowsFeature https://technet.microsoft.com/en-us/library/jj205467.aspx (replaces Add-WindowsFeature which is now an alias)

TODO : If the DC is not the DHCP server, authorize it in AD, figure out how to detect and automate.
Add-DhcpServerInDC -DNSName servername.com

#>

$OperatingSystem = (Get-WmiObject -Class Win32_OperatingSystem).Caption
Switch -regex ($OperatingSystem)
{
    "5.1.3790" {
        "Microsoft Windows Server 2003"
        dism /online /Enable-Feature /FeatureName:DHCPServer
        dism /online /Enable-Feature /FeatureName:DHCPServer-Tools
    }
    "Microsoft Windows 7 Enterprise" {
        dism /online /Enable-Feature /FeatureName:RemoteServerAdministrationTools /FeatureName:RemoteServerAdministrationTools-Roles /FeatureName:RemoteServerAdministrationTools-Roles-DHCP
    }
    "Microsoft Windows Server 2008 R2 Enterprise" {
        Import-Module ServerManager
        Add-WindowsFeature DHCP
        Add-WindowsFeature RSAT-DHCP

        <# Configure
        Get-Service | Where {$_.name –eq 'DHCPServer'}
        Set-Service DHCPServer -StartupType Automatic
        Get-Service DHCPServer | Where {$_.status –eq 'Stopped'} |  Start-Service

        # Not required if DHCP configured prior to promoting to DC
        netsh dhcp add server $env:computername 10.10.10.10

        # Scope
        netsh dhcp server 10.10.10.10 add scope 10.10.10.0 255.255.255.0 "LAN"      
        netsh dhcp server 10.10.10.10 scope 10.10.10.0 add iprange 10.10.10.128 10.10.10.254  
    
        # Exclude range
        netsh dhcp server 10.10.10.10 scope 10.10.10.0 add excluderange 10.10.10.250 10.10.10.254

        # Exclude single address   
        netsh dhcp server 10.10.10.10 scope 10.10.10.0 add excluderange 10.10.10.249 10.10.10.249 
    
        # Reserve an address
        netsh dhcp server 10.10.10.10 scope 10.10.10.0 add reservedip 10.10.10.248 0003FF54888C  
    
        # Default gateway
        netsh dhcp server 10.10.10.10 scope 10.10.10.0 set optionvalue 003 IPADDRESS 10.10.10.1

        # Default dns server
        netsh dhcp server 10.10.10.10 scope 10.10.10.0 set optionvalue 006 IPADDRESS 10.10.10.10
        #>
        }
    "Microsoft Windows Server 2012" {
        Install-WindowsFeature DHCP -IncludeManagementTools
        # Install-WindowsFeature DHCP
    }
    DEFAULT { Write-Host "Nothing to do." }
}
