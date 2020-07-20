@setlocal

@rem Check for python packages updates.
@IF %cimode% EQU 0 set "pyupd="
@IF %cimode% EQU 0 set /p pyupd=Update python packages (y/n):
@IF %cimode% EQU 1 echo Update python packages (y/n):%pyupd%
@echo.
@if /I NOT "%pyupd%"=="y" GOTO endpython
@set pywinsetup=2
@IF NOT EXIST %pythonloc:~0,-10%Removepywin32.exe set pywinsetup=1
@FOR /F "USEBACKQ delims= " %%a IN (`%pythonloc% -c "import sys; print(str(sys.version_info[0])+str(sys.version_info[1]))"`) DO @IF NOT EXIST "%windir%\system32\pythoncom%%a.dll" IF NOT EXIST "%windir%\syswow64\pythoncom%%a.dll" set pywinsetup=0
@if EXIST "%LOCALAPPDATA%\pip" RD /S /Q "%LOCALAPPDATA%\pip"
@for /F "skip=2 delims= " %%a in ('%pythonloc% -W ignore -m pip list -o --disable-pip-version-check') do @(
IF NOT "%%a"=="pywin32" (
%pythonloc% -W ignore -m pip install -U "%%a"
echo.
)
IF "%%a"=="pywin32" IF %pywinsetup% LSS 2 (
%pythonloc% -W ignore -m pip install -U "%%a"
echo.
)
IF "%%a"=="pywin32" IF %pywinsetup% EQU 1 powershell -Command Start-Process "%devroot%\%projectname%\buildscript\modules\pywin32.cmd" -Args "%pythonloc%" -Verb runAs 2>nul
IF "%%a"=="pywin32" IF %pywinsetup% EQU 2 (
echo New version of pywin32 is available.
echo Visit https://github.com/mhammond/pywin32/releases to download it.
echo.
)
)

:endpython
@echo.
@endlocal