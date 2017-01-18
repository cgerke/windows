@echo off

pushd %0%\..

REM Date & Time string
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) DO if '.%%i.'=='.LocalDateTime.' set dts=%%j
set dts=%dts:~0,4%-%dts:~4,2%-%dts:~6,2% %dts:~8,2%:%dts:~10,2%:%dts:~12,6%

REM Add self to login script until complete
set self=%~dp0%~n0%~x0
%WINDIR%\system32\reg.exe add HKLM\Software\Microsoft\Windows\CurrentVersion\Runonce /v Restart /t REG_SZ /d %self% /f

:STEPS
if not exist c:\autounattend1.log (

    echo %dts% AUTOUNATTEND1 > c:\autounattend1.log
    REM for %%i IN (*.bat) do start /MIN /WAIT %~dp0%%i >> c:\autounattend1.log
    start /WAIT %~dp0dotNetFx45_Full_x86_x64.exe /passive
    shutdown -r -f -t 0

) else if not exist c:\autounattend2.log (

    echo %dts% AUTOUNATTEND2 > c:\autounattend2.log
    powershell -command Set-ExecutionPolicy RemoteSigned -force
    %WINDIR%\system32\wusa.exe %~dp0windows6.1-KB2819745-x64-MultiPkg.msu /quiet /forcerestart

) else if not exist c:\autounattend3.log (

    echo %dts% AUTOUNATTEND3 > c:\autounattend3.log
    powershell -command $PSVersionTable >> c:\autounattend3.log
    for %%i IN (*.ps1) do powershell -NoLogo -ExecutionPolicy Bypass -File %~dp0%%i >> c:\autounattend3.log

) else (
    copy c:\*.log c:\autounattend.txt
    del c:\*.log
    %WINDIR%\system32\reg.exe delete HKLM\Software\Microsoft\Windows\CurrentVersion\Runonce /v Restart /f
    shutdown -r -f -t 0
)