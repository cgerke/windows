<# 
IP Address / MacAddress
#>

$OperatingSystem = Get-WmiObject Win32_OperatingSystem
Switch -regex ($OperatingSystem.Version)
{
    "6.1." {
        "Windows 7/Windows Server 2008"
        # Get
        Get-CimInstance win32_networkadapterconfiguration -filter "ipenabled = 'True'" -ComputerName $computername | 
        Select PSComputername,
        @{Name = "IPAddress";Expression = {
        [regex]$rx ="(\d{1,3}(\.?)){4}"
        $rx.matches($_.IPAddress).Value}},MACAddress

        <# Config examples

        #Router
        netsh interface ip set address "Ethernet" static 10.10.10.1 255.255.255.0

        #Domain Controller
        netsh interface ip set address "Ethernet" static 10.10.10.10 255.255.255.0 10.10.10.1
        netsh interface ip add dns "Ethernet" 10.10.10.10

        #Application Server
        netsh interface ip set address "Ethernet" static 10.10.10.100 255.255.255.0 10.10.10.1
        netsh interface ip add dns "Ethernet" 10.10.10.10

        # Secondary DNS
        netsh interface ip add dns "Ethernet" 8.8.8.8   index=2
        
        OR
        
        $wmi = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled ='true'";
        $wmi.EnableStatic("10.10.10.10", "255.255.255.0")
        $wmi.SetGateways("10.10.10.1")
        $wmi.SetDNSServerSearchOrder("10.10.10.10")

        OR

        $wmi = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled ='true'";
        $wmi.EnableDHCP();
        $wmi.SetDNSServerSearchOrder();
        #>


    }
    "6.3.9600" {
        "Windows 2012"
        
        # Get
        Get-NetIPAddress -CimSession $computername -AddressFamily IPv4 | 
        where { $_.InterfaceAlias -notmatch 'Loopback'} |
        Select PSComputername,IPAddress

        <# Config example
        New-NetIPAddress –InterfaceAlias “Ethernet” –IPv4Address "10.10.10.10" –PrefixLength 24 -DefaultGateway 10.10.10.1
        Set-DnsClientServerAddress -InterfaceAlias “Wired Ethernet Connection” -ServerAddresses 10.10.10.10



        #>
    } 
    DEFAULT { Write-Host "Nothing to do." }
}
