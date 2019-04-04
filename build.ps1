# Verbose hack for input line is too long.
param(
   [switch] $Verbose
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
    param([string]$File, [string]$parameters)
    $tmpFile = [IO.Path]::GetTempFileName()
    cmd.exe /c "`"$File`" `"$parameters`" && set > `"$tmpFile`""
    Get-Content $tmpFile | ForEach-Object {
        if($_ -match "^(.*?)=(.*)$"){
            Set-Content "env:\$($matches[1])" $matches[2]
        }
    }
    Remove-Item $tmpFile
}

function Invoke-Extract {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$File
    )
    $7z = "C:\Program Files\7-Zip\7z.exe"
    if ( Test-Path $7z ){
        if ( Test-Path $File ){
            $tmpPath = (Get-Item $File).Basename
            Start-Process -FilePath $7z -ArgumentList "x -y -o""$tmpPath"" ""$File""" -NoNewWindow -Wait
        } else {
            Write-Output "! $(Get-PSCallStack) $File issue."
            Exit
        }
    } else {
        Write-Output "! $(Get-PSCallStack) Unable to extract $File without 7zip."
        Exit
    }

}

# Invoke ADK
Invoke-Cmd -File "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
If ($Verbose) {
    Get-ChildItem env:\
}

# Extract ISO
Invoke-Extract -File "$(Get-Location)\win7_pro_x64.ISO"

## provide a gui too ?
<# Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    Multiselect = $false # Multiple files can be chosen
    Filter      = 'Images (*.iso, *.xml)|*.iso;*.xml' # Specified file types
}

[void]$FileBrowser.ShowDialog()
$file = $FileBrowser.FileName;
If ($FileBrowser.FileNames -like "*\*") {
    # Do something
    $FileBrowser.FileName #Lists selected files (optional)
} else {
    Write-Host "Cancelled by user"
} #>