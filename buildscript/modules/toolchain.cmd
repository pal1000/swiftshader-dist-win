@setlocal ENABLEDELAYEDEXPANSION
@rem Find vswhere tool.
@set msvcver=null
@set msvcname=null
@set vsabi=%abi%
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF %abi%==x86 set vsabi=x64_x86
@IF /I %PROCESSOR_ARCHITECTURE%==x86 IF %abi%==x64 set vsabi=x86_x64
@set vswhere="%ProgramFiles%
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 set vswhere=%vswhere% (x86)
@set vswhere=%vswhere%\Microsoft Visual Studio\Installer\vswhere.exe"

:findcompilers
@set vsenv=null
@set toolset=0

@set totalmsvc=0
@IF EXIST %vswhere% for /F "USEBACKQ tokens=*" %%a IN (`%vswhere% -prerelease -property catalog_productDisplayVersion 2^>^&1`) do @set /a totalmsvc+=1&set msvcversions[!totalmsvc!]=%%a
@set msvccount=0
@IF EXIST %vswhere% for /F "USEBACKQ tokens=*" %%a IN (`%vswhere% -prerelease -property displayName 2^>^&1`) do @set /a msvccount+=1&set msvcnames[!msvccount!]=%%a
@IF %cimode% EQU 0 cls
@echo Available compilers
@IF %totalmsvc% GTR 0 FOR /L %%a IN (1,1,%totalmsvc%) do @echo %%a.!msvcnames[%%a]! v!msvcversions[%%a]!
@echo.
@IF %totalmsvc%==0 (
@echo Error: No compiler found. Cannot continue.
@echo.
@IF %cimode% EQU 0 pause
@exit
)

@rem Select compiler
@IF %cimode% EQU 0 set /p selecttoolchain=Select compiler:
@IF %cimode% EQU 1 echo Select compiler:%selecttoolchain%
@echo.
@set validtoolchain=1
@IF "%selecttoolchain%"=="" (
@echo Invalid entry
@IF %cimode% EQU 0 pause
@IF %cimode% EQU 0 GOTO findcompilers
@IF %cimode% EQU 1 exit
)
@IF %selecttoolchain% LEQ 0 set validtoolchain=0
@IF %selecttoolchain% GTR %totalmsvc% set validtoolchain=0
@IF %validtoolchain%==0 (
@echo Invalid entry
@IF %cimode% EQU 0 pause
@IF %cimode% EQU 0 GOTO findcompilers
@IF %cimode% EQU 1 exit
)

@rem Determine version and build enviroment launcher PATH for selected Visual Studio installation
@set msvccount=0
@for /F "USEBACKQ tokens=*" %%a IN (`%vswhere% -prerelease -property installationPath`) do @set /a msvccount+=1&IF !msvccount!==%selecttoolchain% set vsenv="%%a\VC\Auxiliary\Build\vcvarsall.bat"
@FOR /L %%a IN (1,1,%totalmsvc%) do @IF "%%a"=="%selecttoolchain%" (
set msvcname=!msvcnames[%%a]!
set msvcver=!msvcversions[%%a]!
)

:novcpp
@IF NOT EXIST %vsenv% echo Error: Selected Visual Studio installation lacks Desktop development with C++ workload necessary to build swiftshader.
@IF NOT EXIST %vsenv% IF %cimode% EQU 0 set /p addvcpp=Add Desktop development with C++ workload - y/n:
@IF NOT EXIST %vsenv% IF %cimode% EQU 1 echo Add Desktop development with C++ workload - y/n:%addvcpp%
@IF NOT EXIST %vsenv% echo.
@IF NOT EXIST %vsenv% IF /I NOT "%addvcpp%"=="y" IF %cimode% EQU 0 pause
@IF NOT EXIST %vsenv% IF /I NOT "%addvcpp%"=="y" IF %cimode% EQU 0 GOTO findcompilers
@IF NOT EXIST %vsenv% IF /I NOT "%addvcpp%"=="y" IF %cimode% EQU 1 exit
@IF NOT EXIST %vsenv% %vswhere:~0,-12%vs_installer.exe"
@IF NOT EXIST %vsenv% GOTO findcompilers

:selectedmsvc
@set TITLE=%TITLE% using Visual Studio
@set toolset=%msvcver:~0,2%
@GOTO selectedcompiler

:selectedcompiler
@TITLE %TITLE%
@endlocal&set toolchain=%toolchain%&set vsabi=%vsabi%&set vsenv=%vsenv%&set toolset=%toolset%&set msvcname=%msvcname%&set msvcver=%msvcver%&set TITLE=%TITLE%