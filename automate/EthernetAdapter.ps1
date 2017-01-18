$Host.UI.RawUI.WindowTitle = "Rename Ethernet Adapter..."

$GetWmiObjectParams = @{
    Class = "Win32_NetworkAdapter"
    Filter = "AdapterType='Ethernet 802.3'"
}

Write-Host ("Get the primary ethernet adapter.")
$EthernetAdapter = Get-WmiObject @GetWmiObjectParams| Select-Object -First 1
$EthernetAdapter.NetConnectionID = "Ethernet"
$EthernetAdapter.Put()