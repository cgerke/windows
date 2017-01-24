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
        # netdom join $env:computername /domain:$addomain /userd:"$adnetbios\$aduser" /passwordd:"$adpassword"
        # shutdown -r -f -t 0
        $credential = New-Object System.Management.Automation.PsCredential("$adnetbios\$aduser", (ConvertTo-SecureString "$adpassword" -AsPlainText -Force))
        Add-Computer -DomainName "$adnetbios" -Credential $credential
        Restart-Computer
    }
    "Microsoft Windows Server 2008 R2 Enterprise" {
        # netdom join $env:computername /domain:cgerke.ddns.net /userd:"$adnetbios\$aduser" /passwordd:"$adpassword" /OU:"$serverou"
        # shutdown -r -f -t 0
        $credential = New-Object System.Management.Automation.PsCredential("$adnetbios\$aduser", (ConvertTo-SecureString "$adpassword" -AsPlainText -Force))
        Add-Computer -DomainName "$adnetbios" -Credential $credential -OUPath "$serverou"
        Restart-Computer
    }
    "Microsoft Windows Server 2012" {
        $credential = New-Object System.Management.Automation.PsCredential("$adnetbios\$aduser", (ConvertTo-SecureString "$adpassword" -AsPlainText -Force))
        Add-Computer -DomainName "$adnetbios" -Credential $credential -OUPath "$serverou"
        Restart-Computer
    }
    DEFAULT { Write-Host "Nothing to do." }
}
