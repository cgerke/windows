param(
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo]$File
)

function Invoke-Cmd {
    <#
    .SYNOPSIS
    Execute a cmd file.
    .DESCRIPTION
    Execute a cmd file and import ENV variables.
    .EXAMPLE
    Invoke-Cmd -File file.cmd
    .PARAMETER File
    Mandatory file to execute.
    #>
    [cmdletbinding()]
    param(
        [string]$File,
        [string]$parameters
    )
    $tmpFile = [IO.Path]::GetTempFileName()
    cmd.exe /c "`"$File`" `"$parameters`" && set > `"$tmpFile`""
    Get-Content $tmpFile | ForEach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            Set-Content "env:\$($matches[1])" $matches[2]
        }
    }
    Remove-Item $tmpFile

    # Verbose ENV
    Get-ChildItem env:\
}

function Invoke-FileBrowser {
    <#
    .SYNOPSIS
    Open file dialog.
    .DESCRIPTION
    Open a windows explorer file selector.
    .EXAMPLE
    Invoke-FileBrowser
    #>
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Multiselect = $false # Multiple files can be chosen
        Filter      = 'Image (*.iso)|*.iso' # Specified file types
    }

    [void]$FileBrowser.ShowDialog()
    If ($FileBrowser.FileNames -like "*\*") {
        # Do something
        $FileBrowser.FileName #Lists selected files (optional)
    } else {
        Write-Host "Cancelled by user"
    }
}

function New-ISO {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateScript( {
                If (-Not ($_ | Test-Path) ) {
                    Throw "File does not exist."
                }
                If (-Not ($_ | Test-Path -PathType Leaf) ) {
                    Throw "The Path argument must be a file. Folder paths are not allowed."
                }
                If ($_ -notmatch "(\.iso)") {
                    Throw "The file specified in the path argument must be an iso."
                }
                If (-Not (Get-DiskImage -ImagePath $_ | Get-Volume).DriveLetter ) {
                    Mount-DiskImage -ImagePath $_ -StorageType ISO -PassThru
                }
                Return $true
            })]
        [System.IO.FileInfo]$File
    )

    # install.wim test
    $Drive = (Get-DiskImage -ImagePath $File | Get-Volume).DriveLetter
    If (-Not "$Drive`:\sources\install.wim" | Test-Path ) {
        Throw "Missing install.wim"
    }

    # Working path
    # $Build = [System.IO.Path]::GetRandomFileName()
    $Build = [System.IO.Path]::GetFileNameWithoutExtension($File)

    # Copy image contents
    & Robocopy.exe "$drive`:\" ".\$Build\" /ETA /MIR /R:0 /W:0

    # Customise
    & imagex.exe /info ".\$Build\sources\boot.wim" > ".\$Build\sources\`$OEM$\`$$\BUILD.txt"
    & imagex.exe /info ".\$Build\sources\install.wim" >> ".\$Build\sources\`$OEM$\`$$\BUILD.txt"
    & Robocopy.exe "`$OEM$" ".\$Build\sources\`$OEM$" /ETA /MIR /R:1 /W:1

    # TODO
    # Invoke-FileBrowser as an option

    # autounattend
    Copy-Item ".\$Build.xml" ".\$Build\autounattend.xml"

    $tools    = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\oscdimg'
    $oscdimg  = "$tools\oscdimg.exe"
    $etfsboot = "$tools\etfsboot.com"
    $efisys   = "$tools\efisys.bin"
    $Arguments = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f $etfsboot, $efisys
    Start-Process $oscdimg -args @("-bootdata:$Arguments", '-u2', '-udfver102', ".\$Build", ".\$Build.autounattend.iso") -wait -nonewwindow

    # TODO Test for success then clean-up
    #Remove-Item ".\$Build" -Force

    # Clean up
    Dismount-DiskImage -ImagePath $File
}

# Invoke ADK
Invoke-Cmd -File "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"

# Build OS
If ( $File ) {
    # Get the full path to avoid issues with .\
    $FilePath = Resolve-Path -Path $File
    New-ISO -File "$FilePath"
} Else {
    New-ISO -File $(Invoke-FileBrowser)
}

# TODO
# Build WinPE

# Build USB