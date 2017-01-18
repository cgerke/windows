wpeinit

set root_path=%~dp0

echo.
echo Partition HDD
echo select disk 0
echo clean
echo create partition primary
echo assign letter=C
echo active
echo format fs=ntfs label=Windows quick
echo.

echo.
echo IMAGEX
echo.

echo OR
echo.
echo SETUP AUTOUNATTEND
echo.