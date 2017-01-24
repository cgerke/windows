<# 
SCCM

DISM https://technet.microsoft.com/en-au/library/hh825236.aspx (local only)
Add-WindowsFeature https://msdn.microsoft.com/en-us/library/ee662309.aspx (remote installs too)
Install-WindowsFeature https://technet.microsoft.com/en-us/library/jj205467.aspx (replaces Add-WindowsFeature which is now an alias)

#>
$path = (Get-Item $PSCommandPath).Directory.FullName

$OperatingSystem = (Get-WmiObject -Class Win32_OperatingSystem).Caption
Switch -regex ($OperatingSystem)
{
    "Microsoft Windows 7 Enterprise" {
        Write-Host "ADK"
        Start-Process -FilePath "adk8\adksetup.exe" -ArgumentList '/Features','+','/norestart','/quiet','/ceip','off','/log',"$env:SystemDrive\adk.log" -Wait -NoNewWindow
        Write-Host "SCCM Console"
        Start-Process -FilePath "\SCCM2012R2\SMSSETUP\BIN\I386\consolesetup.exe" -ArgumentList '/q','TargetDir="C:\Program Files\Configuration Manager\Console"','EnableSQM=0' -Wait -NoNewWindow
        Write-Host "WSUS Console"
        Start-Process -FilePath "WSUS\WSUS30-KB972455-x64.exe" -ArgumentList '/q','CONSOLE_INSTALL=1' -Wait -NoNewWindow
    }
    "Microsoft Windows Server 2008 R2 Enterprise" {
        $features = "$env:SystemDrive\dism.log"
        If (!(Test-Path $features)){
            # Vital prerequisites otherwise you will have issues with roles (particularly Application Catalog).
            #
            # Application Server
            dism /LogPath:"$env:SystemDrive\dism-netfx3.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:AppServer
            dism /LogPath:"$env:SystemDrive\dism-netfx3.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:AppServer-UI
            #.NET Framework
            dism /LogPath:"$env:SystemDrive\dism-netfx3.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:NetFx3
            dism /LogPath:"$env:SystemDrive\dism-netfx3.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:WAS-WindowsActivationService
            dism /LogPath:"$env:SystemDrive\dism-netfx3.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:WAS-ProcessModel
            dism /LogPath:"$env:SystemDrive\dism-netfx3.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:WAS-NetFxEnvironment
            dism /LogPath:"$env:SystemDrive\dism-netfx3.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:WAS-ConfigurationAPI
            dism /LogPath:"$env:SystemDrive\dism-netfx3.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:WCF-HTTP-Activation
            dism /LogPath:"$env:SystemDrive\dism-netfx3.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:WCF-NonHTTP-Activation
            # Web server
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-WebServerRole
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-WebServer
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-DefaultDocument
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-StaticContent
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-WindowsAuthentication
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-WebServerManagementTools
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-ManagementConsole
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-ManagementService
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-LegacyScripts
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-LegacySnapIn
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-IIS6ManagementCompatibility
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-Metabase
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-WMICompatibility
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-ManagementScriptingTools
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-HttpRedirect
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-URLAuthorization
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-NetFxExtensibility
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-LoggingLibraries
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-HttpTracing
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-IPSecurity
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-HttpCompressionDynamic
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-ISAPIExtensions
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-ISAPIFilter
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-ASPNET
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-ASP
            dism /LogPath:"$env:SystemDrive\dism-iis.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:IIS-BasicAuthentication
            # BITS
            dism /LogPath:"$env:SystemDrive\dism-bit.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:BITSExtensions-Upload
            dism /LogPath:"$env:SystemDrive\dism-bit.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:BITSExtensions-AdminPack
            # Remote Differential Compression
            dism /LogPath:"$env:SystemDrive\dism-rdc.log" /LogLevel:1 /online /NoRestart /Enable-Feature /FeatureName:MSRDC-Infrastructure
            # Log
            dism /Online /Get-Features /Format:table > $features
            <# Windows Assessment and Deployment Kit (ADK)

            /Features
            OptionId.ApplicationCompatibilityToolkit
            OptionId.DeploymentTools
            OptionId.WindowsPreinstallationEnvironment
            OptionId.UserStateMigrationTool
            OptionId.VolumeActivationManagementTool
            OptionId.WindowsPerformanceToolkit
            OptionId.WindowsAssessmentServices
            OptionId.SqlExpress2012

            or Full

            & adk8\adksetup.exe /Features + /norestart /quiet /ceip off /log $env:SystemDrive\adk.txt
            #>
            Write-Host "ADK"
            Start-Process -FilePath "adk8\adksetup.exe" -ArgumentList '/Features','OptionId.DeploymentTools','OptionId.WindowsPreinstallationEnvironment','OptionId.UserStateMigrationTool','/norestart','/quiet','/ceip','off','/log',"$env:SystemDrive\adk.log" -Wait -NoNewWindow

            # SQL
            Write-Host "SQL"
            Start-Process -FilePath sql2012sp1\Setup.exe -ArgumentList '/ConfigurationFile=sql2012sp1\ConfigurationFile.ini' -Wait
            Write-Host "SQL SP1"
            Start-Process -FilePath sql2012sp1\SQLServer2012SP1-KB2674319-x64-ENU.exe -ArgumentList '/allinstances','/quiet' -Wait

            # WSUS
            <#
            Server GPO

            Computer Configuration -> Policies-Administrative templates-> Windows Component-> Windows Update
            Configure Automatic Updates: Enable
                    Configure automatic updating: 4
                    Scheduled install day: 0 – Every day
                    Scheduled install time: 11:00
            Specify Intranet Microsoft update service location: Enable. "http://YOURSERVER:8530"
            No auto-restart with logged on users for scheduled automatic updates installations : Enable
            Enable client-side targeting : "Servers"

            Workstation GPO
            Computer Configuration -> Policies-> Windows Settings -> Security Settings -> System Services
                Automatic
            Computer Configuration -> Policies-Administrative templates-> Windows Component-> Windows Update
                Allow Automatic Updates immediate installation: Disable
                Allow non-administrators to receive update notifications: Enable
                Configure Automatic Updates: Enable
                    Configure automatic updating: 4
                    Scheduled install day: 0 – Every day
                    Scheduled install time: 05:00
                Target group name for this computer: "Workstations"
                No auto-restart with logged on users for scheduled automatic updates installations: Disable
                Specify Intranet Microsoft update service location: Enable. "http://YOURSERVER:8530"


            Configure Automatic Updates
                Enable
                4 - Auto download and install
                0 - Everyday
                11:00pm
            Specify Intranet Microsoft update service location
                "http://YOURSERVER:8530"
            No auto-restart with logged on users for scheduled automatic updates installations
                Enable
            Enable client-side targeting
                "Workstations"

            #>
            Write-Host "WSUS"
            New-Item -ItemType directory -Path $env:SystemDrive\WSUS
            Start-Process -FilePath "WSUS\WSUS30-KB972455-x64.exe" -ArgumentList '/q','CONTENT_LOCAL=1',"CONTENT_DIR=$env:SystemDrive\WSUS",'DEFAULT_WEBSITE=0','CREATE_DATABASE=1',"SQLINSTANCE_NAME=$env:computername" -Wait -NoNewWindow
            Write-Host "WSUS KBS"
            Start-Process -FilePath "WSUS\WSUS-KB2720211-x64.exe" -ArgumentList '/q' -Wait -NoNewWindow
            Start-Process -FilePath "WSUS\WSUS-KB2734608-x64.exe" -ArgumentList '/q' -Wait -NoNewWindow
            Write-Host "WSUS REPORT VIEWER"
            Start-Process -FilePath "WSUS\reportviewer.exe" -ArgumentList '/q','/l',"$env:SystemDrive\WSUS_ReportViewer.log" -Wait -NoNewWindow
            Write-Host "WSUS CONFIG"
            Start-Process -FilePath "C:\Program Files\Update Services\Tools\WsusUtil.exe" -ArgumentList 'postinstall',"contentdir=$env:SystemDrive\WSUS" -Wait -NoNewWindow

        }Else{
          # // File does not exist
        }
    }
    "Microsoft Windows Server 2012" {
    }
    DEFAULT { Write-Host "Nothing to do." }
}


<# 

Ensure SQL Service, Agent, Reports are running under Domain accounts.

Ensure sms admin is administrator of the sccm server, you could create an AD group "Server Administrators" and add this to all servers via a GPO.
    Computer Configuration -> Policies -> Windows Settings   -> Security Settings -> Restricted Groups
    Add as a member of Administrators

Create the System ManageMent Container
    ADSI Edit -> CN=System -> New Object -> Container -> System Management

Delegate Control
    Active Directory Users and Computers -> CN=SystemSystem Management, CN=System -> All Tasks -> Delegate Control
    Object Types, select Computers
    Type in your SCCM server name
    Create a Custom Task to Delegate
    This folder, existing objects in this folder and creation of new objects in this folder
    General, Property-Specific and Creation-deletion of specific child objects
    FULL CONTROL

Extend the Active Directory schema for Configuration Manager
    Note: Perform the following on the Active Directory Domain Controller as a Domain Administrator
    \SMSSetup\Bin\x64\Extadsch.exe
    C:\ExtADSch.log

Firewall TCP Inbound 1433, 4022 SQL Replication GPO 
    Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Windows Firewall with Advanced Security -> Inbound Rules

Install a Configuration Manager Primary Site
    Configure the Communication method on each site system role

Administration -> Site Configuration -> Servers and Site System Roles, Right click on your server and choose Add Site System Role
    Software update point
    Use this server as the active software update point
    Enable syncronization on a schedule
    Immediately expire a superseded software update
    Add Definition Updates
    Add Office and Windows Products

Enable Discovery Methods

Configure Boundaries
    Boundary Groups -> Create Boundary Group

# Features prequisites are important here, they must all be correct prior or you will have issues enabling these roles.
Add the Application Catalog Web Site Roles
    Servers and Site System Roles -> Add Site System Roles.
    Select both of the Application Catalog roles

    (Monitoring -> System Status -> Component Status to troubleshoot)
    After installing these roles/features, you might have to register ASP.NET with IIS. 
    The simplest way is to open an elevated command prompt: %windir%\Microsoft.NET\Framework64\v4.0.30319>aspnet_regiis.exe –r

Configure Client Agent Settings
    Administration -> Client Settings -> Defaults Clients Settings -> Properties
    Client Policy -> Client policy polling interval -> 15
    Computer Agent -> Default Application Catalog Website
    Computer Agent -> Add default Application Catalog website to Internet Explorer trusted zone -> True
    Computer Agent -> Software updates -> schedule from 7 days to 1 day, this will be because we want to synchronize Endpoint Protection definition updates on a daily basis.
    Computer Agent -> User and Device Affinity -> Allow users to define their primary device -> True.

    (Automatic User Device Affinity can be enabled by modifying the Client Settings policy. Under User and Device Affinity, change the this to Yes for the device and user
    settings. It’s important that the Audit account logon events and Audit logon events are enabled on computers too, as these are used to determine the device affinity.
    This decision should be based on your environment, ie would you really want all software installing automatically if a user logs into another machine)

     Computer Configuration -> Policies-> Windows Settings -> Security Settings -> Local Policies -> Audit Policy -> (Audit account logon events/Audit logon events)

Deploying the Client Agent
 
#>
