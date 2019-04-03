Write-Host "Hello world"

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
Write-Host "Setting envorionment variables for ADK..."
Invoke-CmdScript -script "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
Get-ChildItem env:\