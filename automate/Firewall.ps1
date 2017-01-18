<#

#>
$Host.UI.RawUI.WindowTitle = "Firewall..."
Write-Host ("Disable firewall state for Private locations.")
netsh advfirewall set AllProfiles state off