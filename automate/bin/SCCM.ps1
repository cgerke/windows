<# 
SCCM

These are the steps, the server config is not fully automated as it requires reboots and manual intervention. Working on it...

DISM https://technet.microsoft.com/en-au/library/hh825236.aspx (local only)
Add-WindowsFeature https://msdn.microsoft.com/en-us/library/ee662309.aspx (remote installs too)
Install-WindowsFeature https://technet.microsoft.com/en-us/library/jj205467.aspx (replaces Add-WindowsFeature which is now an alias)
Log files https://technet.microsoft.com/en-us/library/hh427342.aspx#BKMK_EPLog

#>
$path = (Get-Item $PSCommandPath).Directory.FullName
$sccmLog = "$env:SystemDrive\sccm_dism.log"
$adkLog = "$env:SystemDrive\sccm_adk.log"
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
        <# Windows Roles/Features
        - Vital prerequisites otherwise you will have issues with roles (particularly Application Catalog).
        #>

        # Application Server
        dism /online /NoRestart /Enable-Feature /FeatureName:AppServer
        dism /online /NoRestart /Enable-Feature /FeatureName:AppServer-UI
        #.NET Framework
        dism /online /NoRestart /Enable-Feature /FeatureName:NetFx3
        dism /online /NoRestart /Enable-Feature /FeatureName:WAS-WindowsActivationService
        dism /online /NoRestart /Enable-Feature /FeatureName:WAS-ProcessModel
        dism /online /NoRestart /Enable-Feature /FeatureName:WAS-NetFxEnvironment
        dism /online /NoRestart /Enable-Feature /FeatureName:WAS-ConfigurationAPI
        dism /online /NoRestart /Enable-Feature /FeatureName:WCF-HTTP-Activation
        dism /online /NoRestart /Enable-Feature /FeatureName:WCF-NonHTTP-Activation
        # Web server
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-WebServerRole
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-WebServer
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-DefaultDocument
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-StaticContent
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-WindowsAuthentication
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-WebServerManagementTools
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-ManagementConsole
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-ManagementService
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-LegacyScripts
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-LegacySnapIn
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-IIS6ManagementCompatibility
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-Metabase
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-WMICompatibility
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-ManagementScriptingTools
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-HttpRedirect
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-URLAuthorization
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-NetFxExtensibility
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-LoggingLibraries
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-HttpTracing
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-IPSecurity
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-HttpCompressionDynamic
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-ISAPIExtensions
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-ISAPIFilter
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-ASPNET
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-ASP
        dism /online /NoRestart /Enable-Feature /FeatureName:IIS-BasicAuthentication
        # BITS
        dism /online /NoRestart /Enable-Feature /FeatureName:BITSExtensions-Upload
        dism /online /NoRestart /Enable-Feature /FeatureName:BITSExtensions-AdminPack
        # Remote Differential Compression
        dism /online /NoRestart /Enable-Feature /FeatureName:MSRDC-Infrastructure
        # Log
        dism /Online /Get-Features /Format:table > "$sccmLog"

        <# Windows Assessment and Deployment Kit (ADK)
        - OptionId.ApplicationCompatibilityToolkit
        - OptionId.DeploymentTools
        - OptionId.WindowsPreinstallationEnvironment
        - OptionId.UserStateMigrationTool
        - OptionId.VolumeActivationManagementTool
        - OptionId.WindowsPerformanceToolkit
        - OptionId.WindowsAssessmentServices
        - OptionId.SqlExpress2012
        Start-Process -FilePath "adk8\adksetup.exe" -ArgumentList '/Features','OptionId.DeploymentTools','OptionId.WindowsPreinstallationEnvironment','OptionId.UserStateMigrationTool','/norestart','/quiet','/ceip','off','/log',"$env:SystemDrive\adk.log" -Wait -NoNewWindow
        #>
        Write-Host "ADK"
        Start-Process -FilePath "adk8\adksetup.exe" -ArgumentList '/Features','+','/norestart','/quiet','/ceip','off','/log',"$adkLog" -Wait -NoNewWindow

        <# SQL
        https://technet.microsoft.com/en-us/library/dn281933(v=sc.12).aspx
        https://technet.microsoft.com/library/gg682129.aspx
        - Collation is important! SQL_Latin1_General_CP1_CI_AS
        - Ensure SQL Service, Agent, Reports are running under Domain accounts.
        #>

        Write-Host "SQL"
        Start-Process -FilePath sql2012sp1\Setup.exe -ArgumentList '/ConfigurationFile=sql2012sp1\ConfigurationFile.ini' -Wait
        Write-Host "SQL SP1"
        Start-Process -FilePath sql2012sp1\SQLServer2012SP1-KB2674319-x64-ENU.exe -ArgumentList '/allinstances','/quiet' -Wait
        # Restart possibly not necessary yet...
        Restart-Computer

        
    }
    "Microsoft Windows Server 2012" { Write-Host "2012 Nothing to do."   }
    DEFAULT { Write-Host "Nothing to do." }
}


<# SCCM

Ensure sms admin is administrator of the sccm server, you could create an AD group "Server Administrators" and add this to all servers via a GPO.
    Computer Configuration > Policies > Windows Settings > Security Settings > Restricted Groups

Create the System ManageMent Container
    ADSI Edit > CN=System > New Object > Container > System Management

Delegate Control
    Active Directory Users and Computers > CN=SystemSystem Management, CN=System > All Tasks > Delegate Control
        Object Types, select Computers
        Add SCCM server name
        Create a Custom Task to Delegate
        This folder, existing objects in this folder and creation of new objects in this folder
        General, Property-Specific and Creation-deletion of specific child objects
        FULL CONTROL

Extend the Active Directory schema for Configuration Manager
    Note: Perform the following on the Active Directory Domain Controller as a Domain Administrator
    \SMSSetup\Bin\x64\Extadsch.exe

Firewall TCP Inbound 1433, 4022 SQL Replication GPO 
    Computer Configuration > Policies > Windows Settings > Security Settings > Windows Firewall with Advanced Security > Inbound Rules

Install a Configuration Manager Primary Site
    Configure the Communication method on each site system role

Enable Discovery Methods

Configure Boundaries
    Boundary Groups > Create Boundary Group

Add the Application Catalog Web Site Roles
    Servers and Site System Roles > Add Site System Roles > Application Catalog roles

    (Monitoring > System Status > Component Status to troubleshoot)
    After installing these roles/features, you might have to register ASP.NET with IIS. %windir%\Microsoft.NET\Framework64\v4.0.30319>aspnet_regiis.exe –r

Configure Client Agent Settings
    Administration > Client Settings > Defaults Clients Settings > Properties
        Client Policy > Client policy polling interval > 15
        Computer Agent > Default Application Catalog Website
        Computer Agent > Add default Application Catalog website to Internet Explorer trusted zone > True
        Software updates > schedule from 7 days to 1 day, this will be because we want to synchronize Endpoint Protection definition updates on a daily basis.
        User and Device Affinity > Allow users to define their primary device > True.

    (Automatic User Device Affinity can be enabled by modifying the Client Settings policy. Under User and Device Affinity, change this to Yes for the device and user
    settings. It’s important that the Audit account logon events and Audit logon events are enabled on computers too, as these are used to determine the device affinity.
    This decision should be based on your environment, ie would you really want all software installing automatically if a user logs into another machine)

    Computer Configuration > Policies> Windows Settings > Security Settings > Local Policies > Audit Policy > (Audit account logon events/Audit logon events)

    Administration > Client Settings > Custom Client Settings
        Client Policy > Client Policy Polling interval > 5
        Computer Agent > Default Application Catalog Website
        Deploy (next we configure SUP to deploy the agent via updates which is the best practise method) 

    Administration > Client Settings > Custom User Settings
     User and Device Affinity > Allow users to define their primary device > True.
     Deploy

Install WSUS 3.0 SP2 (# Manually install ...you have to stop prior to the config wizard and let SCCM config it...but test this as a script...)
    - Share $env:SystemDrive\WSUS with Everyone
    New-Item -ItemType directory -Path $env:SystemDrive\WSUS
    Start-Process -FilePath "WSUS\WSUS30-KB972455-x64.exe" -ArgumentList '/q','CONTENT_LOCAL=1',"CONTENT_DIR=$env:SystemDrive\WSUS",'DEFAULT_WEBSITE=0','CREATE_DATABASE=1',"SQLINSTANCE_NAME=$env:computername" -Wait -NoNewWindow
    Start-Process -FilePath "WSUS\WSUS-KB2720211-x64.exe" -ArgumentList '/q' -Wait -NoNewWindow
    Start-Process -FilePath "WSUS\WSUS-KB2734608-x64.exe" -ArgumentList '/q' -Wait -NoNewWindow
    Start-Process -FilePath "WSUS\reportviewer.exe" -ArgumentList '/q','/l',"$env:SystemDrive\sccm_reportviewer.log" -Wait -NoNewWindow
    #Write-Host "WSUS CONFIG"
    # Only if using standalone otherwise cancel config wizard and setup via SCCM
    #Start-Process -FilePath "C:\Program Files\Update Services\Tools\WsusUtil.exe" -ArgumentList 'postinstall',"contentdir=$env:SystemDrive\WSUS" -Wait -NoNewWindow

    Administration > Site Configuration > Servers and Site System Roles > Software update point
        Use this server as the active software update point
        Enable syncronization on a schedule
        Immediately expire a superseded software update
        Add Definition Updates
        Add Office and Windows Products

    Configure Active Directory GPOs
        Computer Configuration > Policies > Windows Settings > Security Settings > System Services > Windows Update
        Computer Configuration > Policies > Administrative Templates > Windows Component > Windows Update

    Administration > Site Configuration > Sites
        Settings Ribbon > Client Installation Settings > Software Update-Based Client Installation: Enabled

Configure Endpoint protection
    Administration > Site Configuration > Servers and Site System Roles > Endpoint protection point
        Basic Membership

    Administration > Site Configuration > Sites
        Settings Ribbon > Email notification
    
    Assets & Compliance > Device Collections > <collection> > Properties
        Alerts > View this collection in the Endpoint Protection Dashboard
        All
    
     Administration > Site Configuration > Sites
        Settings Ribbon > Software Update Point > Products > Forefront Endpoint Protection 2010

    Software Library > Software Updates > All Software Updates > Synchronize Software Updates
        This can take hours... refer to wsyncmgr.log
    
Configure SUP to deliver Definition Updates using an Automatic Deployment Rule
    Software Library > Software Updates > Automatic Deployment Rules > Automatic Deployment Rule
        Exisiting software update group
        Software Updates > Date Released or Revised > Last 1 day
        Software Updates > Products > Forefront Endpoint Protection 2010

Configure Custom Client Settings for Endpoint Protection
    Administration > Client Settings > Create Custom Client Device Settings
    Deploy

Configure Custom AntiMalware Policies
    Assets and Compliance > Endpoint Protection > Antimalware Policies > Create Antimalware Policy
    Deploy

Configure the SUP Products to Sync and Perform a Sync
    Administration > Site Configuration > Sites
        Settings Ribbon > Software Update Point > Products > Windows 7

    Software Library > Software Updates > All Software Updates > Synchronize Software Updates
        This can take hours... refer to wsyncmgr.log

    Create a Software Update Group that Contains the Software Updates
        Software Library > Software Updates
            Specify Search Criteria for Software Updates
                Product = Windows 7
                Bulletin ID =MS
                Expired = No
                Superseded = No
            > Create Software Update Group
        Deploy

    Duplicate the step above and create a second Software Update Group that Contains the Software Updates for Build and Capture Tasks later.

Enable PXE
    Administration > Site Configuration > Servers and Site System Roles > PXE
    UDP ports 67, 68, 69 and 4011
    Enable all options
    Allow User Device Affinity with Automatic Approval

Add the Windows 7 X64 operating system image
    Software Library > Operating Systems > Operating System Installers
    Distribute Content

Customise  boot images and then Distribute the Boot images to DP's
    Software Library > Operating Systems > Boot images > * > Properties
        Customization > Enable Command Support
        Data Source > Deploy this boot image from the PXE service Point
        Distribute Content
        SMSProv.log

Create and then Distribute the Configmgr Client Package to DP's
    Software Library > Application Management > Packages > Create Package from Definition
        Configuration Manager Client Upgrade
        Always obtain source files from a source folder
        Network path (unc name) > \\server\sms_xxx\client
        Distribute Content

Create the Build and Capture Task Sequence
    Software Library > Operating Systems > Task Sequences
        Build and Capture a reference operating system image
            X64 boot image
            DON'T enter product key
            ENTER administrator password
            Join a workgroup (keeps the build clean of domain changes)
            Microsoft Configuration Manager Client Upgrade package created earlier
                Installation Properties > SMSMP=SCCMSERVER FQDN (Windows update switch)
            All software updates
            \sources\os\captures\

Import Computer Information
    Assets and Compliance > Devices > Import Computer Information > Import single computers
    Add computers to the Build and Capture collection create earlier

Software Library > Operating Systems > Task Sequences
    Deploy to the Build and Capture collection
        Available
        Make available to boot media and PXE

Enable the Network Access Account
    Administration > Site Configuration > Sites > * > Configure Site Components > Software Distribution > Network Access Account

PXE boot the capture Machine

(any errors about packages not being found, then enable the following setting in Data Access for all packages in your task sequence including
the boot image:- copy the contents in this package to a package share on distribution points)

#>