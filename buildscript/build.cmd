@set TITLE=Building SwiftShader
@TITLE %TITLE%

@rem Determine swiftshader build environment root folder and convert the path to it into DOS 8.3 format to avoid quotes mess.
@cd "%~dp0"
@cd ..\..\
@for %%a in ("%cd%") do @set devroot=%%~sa
@IF "%devroot:~-1%"=="\" set devroot=%devroot:~0,-1%

@set projectname=swiftshader-dist-win
@set "ERRORLEVEL="

@rem Detect and activate ci mode
@set cimode=0
@IF NOT "%1"=="" set cimode=1
@IF %cimode% EQU 1 call %devroot%\%projectname%\buildscript\ci\%1.cmd

@rem Select target architecture
@call %devroot%\%projectname%\buildscript\modules\abi.cmd

@rem Analyze environment. Get each dependency status: 0=missing, 1=standby/load manually in PATH, 2=cannot be unloaded.
@rem Not all dependencies can have all these states.

@rem Search for compiler toolchain. Hard fail if none found
@call %devroot%\%projectname%\buildscript\modules\toolchain.cmd

@rem Search for Python. State tracking is pointless as it is loaded once and we are done. Hard fail if missing.
@call %devroot%\%projectname%\buildscript\modules\discoverpython.cmd
@call %devroot%\%projectname%\buildscript\modules\pythonpackages.cmd

@rem Build throttle.
@call %devroot%\%projectname%\buildscript\modules\throttle.cmd

@rem Version control
@call %devroot%\%projectname%\buildscript\modules\git.cmd

@rem Check for remaining dependencies: cmake, ninja.
@call %devroot%\%projectname%\buildscript\modules\cmake.cmd
@call %devroot%\%projectname%\buildscript\modules\ninja.cmd

@rem SwiftShader build.
@call %devroot%\%projectname%\buildscript\modules\%projectname:~0,-9%.cmd

@rem Dump build environment information
@call %devroot%\%projectname%\buildscript\modules\envdump.cmd

@IF /I "%1"=="x86-llvm10" echo --------------------------------------------
@IF /I "%1"=="x64-llvm10" echo --------------------------------------------
@IF /I "%1"=="x86-subzero" echo ---------------------------------------------
@IF /I "%1"=="x64-subzero" echo ---------------------------------------------
@IF %cimode% EQU 1 echo Build job %1 completed successfully.
@IF /I "%1"=="x86-llvm10" echo --------------------------------------------
@IF /I "%1"=="x64-llvm10" echo --------------------------------------------
@IF /I "%1"=="x86-subzero" echo ---------------------------------------------
@IF /I "%1"=="x64-subzero" echo ---------------------------------------------
@IF %cimode% EQU 1 echo.