@set TITLE=Building SwiftShader
@TITLE %TITLE%

@rem Determine swiftshader build environment root folder and convert the path to it into DOS 8.3 format to avoid quotes mess.
@cd "%~dp0"
@cd ..\..\
@for %%a in ("%cd%") do @set devroot=%%~sa

@rem Select target architecture
@call %devroot%\vk-swiftshader-dist\buildscript\modules\abi.cmd

@rem Analyze environment. Get each dependency status: 0=missing, 1=standby/load manually in PATH, 2=cannot be unloaded.
@rem Not all dependencies can have all these states.

@rem Search for compiler toolchain. Hard fail if none found
@call %devroot%\vk-swiftshader-dist\buildscript\modules\toolchain.cmd

@rem Search for Python. State tracking is pointless as it is loaded once and we are done. Hard fail if missing.
@call %devroot%\vk-swiftshader-dist\buildscript\modules\discoverpython.cmd
@call %devroot%\vk-swiftshader-dist\buildscript\modules\pythonpackages.cmd

@rem Build throttle.
@call %devroot%\vk-swiftshader-dist\buildscript\modules\throttle.cmd

@rem Version control
@call %devroot%\vk-swiftshader-dist\buildscript\modules\git.cmd

@rem Check for remaining dependencies: cmake, ninja.
@call %devroot%\vk-swiftshader-dist\buildscript\modules\cmake.cmd
@call %devroot%\vk-swiftshader-dist\buildscript\modules\ninja.cmd

@rem SwiftShader build.
@call %devroot%\vk-swiftshader-dist\buildscript\modules\swiftshader.cmd

@rem Binary resource editor
@call %devroot%\vk-swiftshader-dist\buildscript\modules\resourcehacker.cmd

@rem Dump build environment information
@call %devroot%\vk-swiftshader-dist\buildscript\modules\envdump.cmd

@rem Create distribution
@call %devroot%\vk-swiftshader-dist\buildscript\modules\dist.cmd