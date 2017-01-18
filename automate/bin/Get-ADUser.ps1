Get-ADUser -filter *
Get-ADUser -filter * -Properties mail |Select SAMAccountName, Mail
Get-ADUser -filter * -Properties mail |Select SAMAccountName, Mail | Export-Csv -Path C:\ADUser.csv
