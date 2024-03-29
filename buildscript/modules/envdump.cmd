@setlocal
@IF NOT EXIST %devroot%\%projectname%\dist md %devroot%\%projectname%\dist
@IF NOT EXIST %devroot%\%projectname%\dist\buildinfo md %devroot%\%projectname%\dist\buildinfo
@IF %cimode% EQU 0 set "enableenvdump="
@IF %cimode% EQU 0 set /p enableenvdump=Do you want to dump build environment information to a text file (y/n):
@IF %cimode% EQU 1 echo Do you want to dump build environment information to a text file (y/n):%enableenvdump%
@echo.
@IF /I NOT "%enableenvdump%"=="y" GOTO skipenvdump
@echo Dumping build environment information. This will take a short while...
@echo.
@echo Build environment>%devroot%\%projectname%\dist\buildinfo\environment.txt
@echo ----------------->>%devroot%\%projectname%\dist\buildinfo\environment.txt

@rem Dump Windows version
@FOR /F "USEBACKQ tokens=2 delims=[" %%a IN (`ver`) DO @set winver=%%a
@set winver=%winver:~0,-1%
@FOR /F "USEBACKQ tokens=2 delims= " %%a IN (`echo %winver%`) DO @set winver=%%a
@FOR /F "USEBACKQ tokens=1-3 delims=." %%a IN (`echo %winver%`) DO @set winver=%%a.%%b.%%c
@echo Windows %winver%>>%devroot%\%projectname%\dist\buildinfo\environment.txt

@rem Dump 7-Zip version and compression level
@set sevenzpath=1
@CMD /C EXIT 0
@where /q 7z.exe
@if NOT "%ERRORLEVEL%"=="0" set sevenzpath=0
@IF %sevenzpath% EQU 1 set exitloop=1
@IF %sevenzpath% EQU 1 FOR /F "tokens=2 USEBACKQ delims= " %%a IN (`7z.exe 2^>^&1`) DO @IF defined exitloop (
set "exitloop="
SET sevenzipver=%%a
)
@IF NOT defined sevenzipver IF EXIST %devroot%\%projectname%\buildscript\assets\sevenzip.txt set /p sevenzipver=<%devroot%\%projectname%\buildscript\assets\sevenzip.txt
@IF defined sevenzipver echo 7-Zip %sevenzipver%>>%devroot%\%projectname%\dist\buildinfo\environment.txt

@rem Get Git version
@IF NOT %gitstate%==0 FOR /F "USEBACKQ tokens=3" %%a IN (`git --version`) do @set gitver=%%a
@IF NOT %gitstate%==0 set "gitver=%gitver:.windows=%"
@IF defined gitver echo Git %gitver%>>%devroot%\%projectname%\dist\buildinfo\environment.txt

@rem Dump Visual Studio environment
@echo %msvcname% v%msvcver%>>%devroot%\%projectname%\dist\buildinfo\environment.txt
@call %vsenv% %vsabi%>nul 2>&1
@echo Windows SDK %WindowsSDKVersion:~0,-1%>>%devroot%\%projectname%\dist\buildinfo\environment.txt

@rem Dump Python environment
@echo Python %pythonver%>>%devroot%\%projectname%\dist\buildinfo\environment.txt
@echo.>>%devroot%\%projectname%\dist\buildinfo\environment.txt
@echo Python packages>>%devroot%\%projectname%\dist\buildinfo\environment.txt
@echo --------------->>%devroot%\%projectname%\dist\buildinfo\environment.txt
@FOR /F "USEBACKQ skip=2 tokens=*" %%a IN (`%pythonloc% -W ignore -m pip list --disable-pip-version-check`) do @echo %%a>>%devroot%\%projectname%\dist\buildinfo\environment.txt
@echo.>>%devroot%\%projectname%\dist\buildinfo\environment.txt

@rem Get CMake version
@IF "%cmakestate%"=="1" set PATH=%devroot%\cmake\bin\;%PATH%
@IF NOT "%cmakestate%"=="0" IF NOT "%cmakestate%"=="" set exitloop=1&for /f "tokens=3 USEBACKQ" %%a IN (`cmake --version`) do @if defined exitloop set "exitloop="&echo CMake %%a>>%devroot%\%projectname%\dist\buildinfo\environment.txt

@rem Get Ninja version
@IF "%ninjastate%"=="1" set PATH=%devroot%\ninja\;%PATH%
@IF NOT "%ninjastate%"=="0" IF NOT "%ninjastate%"=="" for /f "USEBACKQ" %%a IN (`ninja --version`) do @echo Ninja %%a>>%devroot%\%projectname%\dist\buildinfo\environment.txt

@rem Finished environment information dump.
@echo Done.
@echo Environment information has been written to %devroot%\%projectname%\dist\buildinfo\environment.txt.
@echo.

:skipenvdump
@endlocal
@IF %cimode% EQU 0 pause
@IF %cimode% EQU 0 exit