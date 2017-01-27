Get-WindowsFeature -Name *Teln*
Get-WindowsFeature | where {$_.InstallState -eq "Installed"}
Get-WindowsFeature | where {$_.Name -eq "Wow64-Support"}
Get-WindowsFeature | where {$_.DisplayName -eq "Wow64 Support"}