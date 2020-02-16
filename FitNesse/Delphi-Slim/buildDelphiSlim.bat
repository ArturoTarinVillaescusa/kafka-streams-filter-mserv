SETLOCAL

if defined BDS call "%BDS%\bin\rsvars.bat"
if not defined BDS call rsvars.bat

set Desarrollo=%CD%
Set PATH=%PATH%;%Desarrollo%\Test\bin

set DOTNETVERSION=3.5
set PROJECT=DelphiSlimGroup.groupproj
set RELEASECONFIG=release
set DOTNETDIR=v%DOTNETVERSION%
set NETDIR=%SYSTEMROOT%\Microsoft.Net\Framework\%DOTNETDIR%
set MSCLEANPARAMS=%PROJECT% /v:n /t:Clean /tv:%DOTNETVERSION% /p:Config=release
set MSBUILDPARAMS=%PROJECT% /v:n /t:Build /tv:%DOTNETVERSION% /p:Config=release

::Clean
set MSBUILDCALL=%NETDIR%\msbuild.exe %MSCLEANPARAMS%
call %MSBUILDCALL%

::Build
set MSBUILDCALL=%NETDIR%\msbuild.exe %MSBUILDPARAMS%
call %MSBUILDCALL%

ENDLOCAL
