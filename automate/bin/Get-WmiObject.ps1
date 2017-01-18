
# Operating System
Get-WmiObject -Class Win32_OperatingSystem -ComputerName .
Get-WmiObject -Class Win32_OperatingSystem -ComputerName . | Select-Object -Property BuildNumber,BuildType,OSType,ServicePackMajorVersion,ServicePackMinorVersion

# Hotfixes
Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName .

# Users
Get-WmiObject -Class Win32_OperatingSystem -ComputerName . | Select-Object -Property NumberOfLicensedUsers,NumberOfUsers,RegisteredUser

# Disk space
Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -ComputerName .

# Logged on user
Get-WmiObject -Class Win32_ComputerSystem -Property UserName -ComputerName .

# Computer local time
Get-WmiObject -Class Win32_LocalTime -ComputerName . | Select-Object -Property [a-z]*

# Service Status
Get-WmiObject -Class Win32_Service -ComputerName . | Select-Object -Property Status,Name,DisplayName
