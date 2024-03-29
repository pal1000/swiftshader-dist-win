@setlocal ENABLEDELAYEDEXPANSION
@rem First remove Python UWP loader from PATH (see https://github.com/pal1000/mesa-dist-win/issues/23)
@SET PATH=!PATH:;%LOCALAPPDATA%\Microsoft\WindowsApps=!

@REM Try locating all Python versions via Python Launcher.
@SET pythonloc=python.exe

@rem Check if Python launcher is installed.
@CMD /C EXIT 0
@where /q py.exe
@if NOT "%ERRORLEVEL%"=="0" GOTO nopylauncher

@rem Count and list supported python installations
@set pythontotal=0
@FOR /F delims^=^ eol^= %%a IN ('py -0 2^>nul') do @IF NOT "%%a"=="" FOR /F tokens^=1^ eol^= %%b IN ("%%a") do @FOR /F "tokens=1-2 delims=. " %%c IN ('py %%b -c "import sys; print(sys.version)"') DO @(
@set goodpython=1
@if %%c LSS 3 set goodpython=0
@if %%c EQU 3 if %%d LSS 5 set goodpython=0
@IF !goodpython!==1 set /a pythontotal+=1
@IF !pythontotal!==1 echo Select Python installation
@IF !goodpython!==1 echo !pythontotal!. %%a
@IF !goodpython!==1 set pyl[!pythontotal!]=%%b
)
@IF %pythontotal%==0 echo WARNING: No suitable Python installation found by Python launcher.
@IF %pythontotal%==0 echo Python 3.5 and newer is required.
@IF %pythontotal%==0 echo.
@IF %pythontotal%==0 GOTO nopylauncher
@IF %pythontotal% GTR 0 echo.

:pyselect
@IF %cimode% EQU 0 set "pyselect="
@IF %cimode% EQU 0 set /p pyselect=Select Python version by entering its index from the table above:
@IF %cimode% EQU 1 echo Select Python version by entering its index from the table above:%pyselect%
@echo.
@IF "%pyselect%"=="" echo Invalid entry.
@IF "%pyselect%"=="" IF %cimode% EQU 0 pause
@IF "%pyselect%"=="" echo.
@IF "%pyselect%"=="" IF %cimode% EQU 0 GOTO pyselect
@IF "%pyselect%"=="" IF %cimode% EQU 1 exit
@IF %pyselect% LEQ 0 echo Invalid entry.
@IF %pyselect% LEQ 0 IF %cimode% EQU 0 pause
@IF %pyselect% LEQ 0 echo.
@IF %pyselect% LEQ 0 IF %cimode% EQU 0 GOTO pyselect
@IF %pyselect% LEQ 0 IF %cimode% EQU 1 exit
@IF %pyselect% GTR %pythontotal% echo Invalid entry.
@IF %pyselect% GTR %pythontotal% IF %cimode% EQU 0 pause
@IF %pyselect% GTR %pythontotal% echo.
@IF %pyselect% GTR %pythontotal% IF %cimode% EQU 0 GOTO pyselect
@IF %pyselect% GTR %pythontotal% IF %cimode% EQU 1 exit

@rem Locate selected Python installation
@FOR /F delims^=^ eol^= %%a IN ('py !pyl[%pyselect%]! -c "import sys; print(sys.executable)"') DO @set pythonloc=%%~sa
@GOTO loadpypath

:nopylauncher
@rem Missing Python launcher fallback code path.
@rem Check if Python is in PATH or if it is provided as a local depedency.
@CMD /C EXIT 0
@IF %pythonloc%==python.exe where /q python.exe
@if NOT "%ERRORLEVEL%"=="0" set pythonloc=%devroot%\python\python.exe
@IF %pythonloc%==%devroot%\python\python.exe IF NOT EXIST %pythonloc% (
@echo Python is unreachable. Cannot continue.
@echo.
@IF %cimode% EQU 0 pause
@exit
)
@IF %pythonloc%==python.exe set exitloop=1
@IF %pythonloc%==python.exe FOR /F "tokens=* USEBACKQ" %%a IN (`where /f python.exe`) DO @IF defined exitloop (
set "exitloop="
SET pythonloc=%%~sa
)

:loadpypath
@REM Load Python in PATH to convince CMake to use the selected version and avoid other potential problems.
@CMD /C EXIT 0
@set pypath=1
@where /q python.exe
@if NOT "%ERRORLEVEL%"=="0" set pypath=0
@IF %pypath%==1 set exitloop=1
@IF %pypath%==1 FOR /F "tokens=* USEBACKQ" %%a IN (`where /f python.exe`) DO @IF defined exitloop (
set "exitloop="
SET pypath=%%~sa
)
@IF NOT %pypath%==%pythonloc% set PATH=%pythonloc:~0,-10%Scripts\;%pythonloc:~0,-10%;%PATH%

:pyver
@rem Identify Python version.
@FOR /F "USEBACKQ delims= " %%a IN (`%pythonloc% -c "import sys; print(sys.version)"`) DO @SET fpythonver=%%a

@rem Check if Python version is not too old.
@set goodpython=1
@FOR /F "USEBACKQ tokens=1-2 delims=." %%a IN (`%pythonloc% -c "import sys; print(str(sys.version_info[0])+'.'+str(sys.version_info[1]))"`) DO @(
@if %%a LSS 3 set goodpython=0
@if %%a EQU 3 if %%b LSS 5 set goodpython=0
)
@IF %goodpython% EQU 0 (
@echo Your Python version is too old. Only Python 3.5 and newer is supported.
@echo.
@IF %cimode% EQU 0 pause
@exit
)
@echo Using Python %fpythonver% from %pythonloc%.
@echo.
@endlocal&SET PATH=%PATH%&set pythonver=%fpythonver%&set pythonloc=%pythonloc%