# Invoking DandISetEnv.bat to set environment variables.
function Invoke-CmdScript {
    param([string]$script, [string]$parameters)
    $tempFile = [IO.Path]::GetTempFileName()
    cmd /c "`"$script`" `"$parameters`" && set > `"$tempFile`""
    Get-Content $tempFile | Foreach-Object {
        if($_ -match "^(.*?)=(.*)$"){
            Set-Content "env:\$($matches[1])" $matches[2]
        }
    }
    Remove-Item $tempFile
}

Invoke-CmdScript -script "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
Get-ChildItem env:\

#& "C:\Program Files\7-Zip\7z.exe" x -y -o\ISO indows_7_pro_x64.ISO.iso