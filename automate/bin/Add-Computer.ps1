<#
Active Directory Join

netdom https://technet.microsoft.com/en-us/library/cc772217(v=ws.11).aspx
Add-Computer

#>

$addomain = "cgerke.ddns.net"
$adnetbios = "cgerke"
$aduser = "join"
$adpassword = "TellEvery1!"
$serverou = "OU=Servers,DC=cgerke,DC=ddns,DC=net"

# $OperatingSystem = Get-WmiObject Win32_OperatingSystem
# Switch -regex ($OperatingSystem.Version)
$OperatingSystem = (Get-WmiObject -Class Win32_OperatingSystem).Caption
Switch -regex ($OperatingSystem)
{
    "Microsoft Windows 7 Enterprise" {
        # netdom add $env:computername /domain:$addomain /userd:"$adnetbios\$aduser" /passwordd:*
        netdom join $env:computername /domain:$addomain /userd:"$adnetbios\$aduser" /passwordd:"$adpassword"
        shutdown -r -f -t 0
    }
    "Microsoft Windows Server 2008 R2 Enterprise" {
        netdom join $env:computername /domain:cgerke.ddns.net /userd:"$adnetbios\$aduser" /passwordd:"$adpassword" /OU:"$serverou"
        shutdown -r -f -t 0
        }
    "Microsoft Windows Server 2012" {
        # TODO TESTING
        #$path = (Get-Item $PSCommandPath).Directory.FullName
        #$password = cat $path\Add-Computer.txt | convertto-securestring
        #$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $adnetbios\$aduser, $adpassword

        # todo - detect plaform
        # Add-Computer -DomainName $addomain -OUPath "$serverou" -Credential $credential
        # Restart-Computer

    }
    DEFAULT { Write-Host "Nothing to do." }
}
