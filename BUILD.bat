@echo off

REM Date & Time string
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) DO if '.%%i.'=='.LocalDateTime.' set dts=%%j
set dts=%dts:~0,4%-%dts:~4,2%-%dts:~6,2% %dts:~8,2%:%dts:~10,2%:%dts:~12,6%

REM Root directory
set root_path=%~dp0
cd %root_path%

REM Script filename
set script_name=%~n0

REM Working directory
set working_path=%root_path%%build_type%_TMP

echo.
echo BUILD MEDIA
echo.
echo 1 - 7ENT
echo 2 - 7PRO
echo 3 - 2008R2SP1
echo 4 - 2012R2
echo 5 - 2016
echo 6 - WINPE ISO
echo 7 - WINPE USB
echo 9 - EXIT
echo.

SET /P B=Type 1, 2, 3, 4, 5 or 9 then press ENTER:
IF %B%==1 set build_type=7ENT
IF %B%==2 set build_type=7PRO
IF %B%==3 set build_type=2008R2SP1
IF %B%==4 set build_type=2012R2
IF %B%==5 set build_type=2016
IF %B%==6 GOTO WINPE_ISO
IF %B%==7 GOTO WINPE_USB
IF %B%==9 GOTO EOF

if /I "%OSCDImgRoot%"=="" (
    echo ADK administrator required
    "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
    echo >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    GOTO EOF
) else (
    echo %dts% %OSCDImgRoot% >> BUILD.txt
)

REM Sets the PROCESSOR_ARCHITECTURE according to native platform for x86 and x64. 
if /I %PROCESSOR_ARCHITECTURE%==x86 (
    if NOT "%PROCESSOR_ARCHITEW6432%"=="" (
        set PROCESSOR_ARCHITECTURE=%PROCESSOR_ARCHITEW6432%
    )
) else if /I NOT %PROCESSOR_ARCHITECTURE%==amd64 (
    @echo Not implemented for PROCESSOR_ARCHITECTURE of %PROCESSOR_ARCHITECTURE%.
)

echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:WINDOWS
echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM Extract ISO based on %build_type% to the %root_path% working directory
if exist %root_path%%build_type%.iso (
    if not exist %working_path%\sources\install.wim (
        call 7z x -y -o%working_path% %root_path%%build_type%.iso
    )
) else (
    echo Missing ISO
)

REM Remaster ISO
echo %working_path%\sources\install.wim
if exist %working_path%\sources\install.wim (
    imagex /info "%working_path%\sources\boot.wim" >> BUILD.txt
    imagex /info "%working_path%\sources\install.wim" >> BUILD.txt
    robocopy %root_path%automate %working_path%\automate /MIR /R:1 /W:1
    copy /Y %root_path%automate\autounattend_%build_type%.xml %working_path%\autounattend.xml
    oscdimg -l%build_type% -m -o -u2 -udfver102 -bootdata:2#p0,e,b"%OSCDImgRoot%\etfsboot.com"#pEF,e,b"%OSCDImgRoot%\efisys.bin" %working_path% %build_type%_unattend.iso
    REM rmdir %working_path% /S /Q
) else (
    echo Missing ESD
)
GOTO EOF

echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:WINPE_ISO
echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set build_type=WINPE

REM Working directory
set working_path=%root_path%%build_type%_TMP

REM WORKING DIRECTORY
if not exist "%working_path%" (
    call copype %PROCESSOR_ARCHITECTURE% %working_path%
    TIMEOUT /T 5 >nul
)

if exist "%working_path%\media\sources\boot.wim" (
    imagex /info "%working_path%\media\sources\boot.wim" >> BUILD.txt
    call dism /Mount-Image /ImageFile:"%working_path%\media\sources\boot.wim" /index:1 /MountDir:"%working_path%\mount"
)

if exist "%working_path%\mount\Windows\System32\Startnet.cmd" (
    copy /Y %root_path%automate\startnet.cmd %working_path%\mount\Windows\System32\startnet.cmd
    notepad %working_path%\mount\Windows\System32\Startnet.cmd
    pause
    cd %root_path%
    call dism /Unmount-Image /MountDir:"%working_path%\mount" /commit
    call MakeWinPEMedia /ISO "%working_path%" "%build_type%.iso"
)
GOTO EOF

echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:WINPE_USB
echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set build_type=WINPE_USB

REM Working directory
set working_path=%root_path%%build_type%_TMP

REM WORKING DIRECTORY
if not exist "%working_path%" (
    call copype %PROCESSOR_ARCHITECTURE% %working_path%
    TIMEOUT /T 5 >nul
)

echo Manually setup USB drive for now...
echo Needs work...assumes D drive
echo.
echo diskpart
echo list disk
echo select disk disk#
echo clean
echo create partition primary
echo format quick fs=fat32 label="WinPE"
echo assign letter="D"
echo exit

echo MakeWinPEMedia /UFD "%working_path%" D:
echo dism /Mount-Image /ImageFile:"D:\sources\boot.wim" /index:1 /MountDir:"%working_path%\mount"
pause

if exist "%working_path%\mount\Windows\System32" (
    copy /Y %root_path%automate\winpe\* %working_path%\mount\Windows\System32\
    notepad %working_path%\mount\Windows\System32\Startnet.cmd
    pause
    cd %root_path%
    call dism /Unmount-Image /MountDir:"%working_path%\mount" /commit
)

GOTO EOF

:EOF