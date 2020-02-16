SETLOCAL

if defined BDS call "%BDS%\bin\rsvars.bat"
if not defined BDS call rsvars.bat

set Desarrollo=%CD%
Set PATH=%PATH%;%Desarrollo%\Test\bin

call Test\release\Win32\DelphiSlimTests.exe -exit:continue

ENDLOCAL



