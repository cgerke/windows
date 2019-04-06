@echo off
REM Runs as SYSTEM.
REM Runs after setup completes but before any synchronous or asynchronous commands are executed via unattend files.
REM Requires use of a full paths.

REM Date & Time string
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) DO if '.%%i.'=='.LocalDateTime.' set dts=%%j
set dts=%dts:~0,4%-%dts:~4,2%-%dts:~6,2% %dts:~8,2%:%dts:~10,2%:%dts:~12,6%

REM Cleanup
del /Q /F %windir%\system32\sysprep\autounattend.xml
del /Q /F %windir%\panther\autounattend.xml
del /Q /F %windir%\system32\sysprep\unattend.xml
del /Q /F %windir%\panther\unattend.xml

echo %dts% SETUPCOMPLETE SP1 > c:\autounattend.log
start /WAIT %windir%\Setup\Windows6.1-KB976932-X64.exe /quiet /nodialog /norestart