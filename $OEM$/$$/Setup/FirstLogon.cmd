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

    echo %dts% DOTNET > c:\autounattend1.log
    start /WAIT %windir%\Setup\NDP472-KB4054530-x86-x64-AllOS-ENU.exe /q /norestart
    shutdown -r -f -t 0

) else if not exist c:\autounattend2.log (

    echo %dts% WMF4 > c:\autounattend2.log
    %WINDIR%\system32\wusa.exe %windir%\Setup\windows6.1-KB2819745-x64-MultiPkg.msu /quiet /norestart
    shutdown -r -f -t 0

) else (
    copy /b c:\*.log C:\Windows\Setup\setup.log
    del c:\*.log
    %WINDIR%\system32\reg.exe delete HKLM\Software\Microsoft\Windows\CurrentVersion\Runonce /v Restart /f
    shutdown -r -f -t 0
)