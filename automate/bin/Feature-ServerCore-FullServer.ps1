<# 
Switch from ServerCore to GUI

https://blogs.technet.microsoft.com/canitpro/2012/10/02/from-server-core-to-gui-to-minshell/
https://blogs.technet.microsoft.com/john_taylor/2013/01/08/converting-from-server-2012-core-install-to-full-gui/

Dism /online /enable-feature /featurename:ServerCore-FullServer /featurename:Server-Gui-Shell /featurename:Server-Gui-Mgmt
-or-

#>

Import-Module Dism 
Enable-WindowsOptionalFeature –online -Featurename ServerCore-FullServer,Server-Gui-Shell,Server-Gui-Mgmt
