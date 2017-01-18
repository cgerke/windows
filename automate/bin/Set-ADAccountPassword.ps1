Import-Module ActiveDirectory

$adpassword = Read-Host "Enter new password." -AsSecureString

<# or without user intervention.
$adpassword = ConvertTo-SecureString -String "Monday@123" -AsPlainText -Force
#>

$aduser = Read-Host "Enter username."

Set-ADAccountPassword $aduser -NewPassword $adpassword -Reset
Set-ADUser $aduser -ChangePasswordAtLogon $true
