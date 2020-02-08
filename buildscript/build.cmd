@set TITLE=Building SwiftShader
@TITLE %TITLE%

@rem Determine swiftshader build environment root folder and convert the path to it into DOS 8.3 format to avoid quotes mess.
@cd "%~dp0"
@cd ..\..\
@for %%a in ("%cd%") do @set devroot=%%~sa

@set projectname=swiftshader-dist-win

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
@call %devroot%\%projectname%\buildscript\modules\swiftshader.cmd

@rem Binary resource editor
@call %devroot%\%projectname%\buildscript\modules\resourcehacker.cmd

@rem Dump build environment information
@call %devroot%\%projectname%\buildscript\modules\envdump.cmd

@rem Create distribution
@call %devroot%\%projectname%\buildscript\modules\dist.cmd