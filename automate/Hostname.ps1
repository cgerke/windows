$Host.UI.RawUI.WindowTitle = "Rename Host..."

$GetWmiObjectParams = @{
    Class = "Win32_NetworkAdapter"
    Filter = "AdapterType='Ethernet 802.3'"
}

$MacAddress = Get-WmiObject @GetWmiObjectParams | select -exp MacAddress | Select-Object -First 1
$MacAddress = $MacAddress -Replace ":",""

if($env:computername -ne $MacAddress){
    Write-Host ("Host: " + $MacAddress)
    Rename-Computer $MacAddress
}