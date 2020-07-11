@setlocal
@rem Look for CMake build generator.
@IF %cmakestate%==0 echo Fatal: CMake is required to build swiftshader.
@IF %cmakestate%==0 GOTO skipbuild

@IF %gitstate%==0 IF NOT EXIST %devroot%\swiftshader echo Fatal: Failed to obtain swiftshader source code.
@IF %gitstate%==0 IF NOT EXIST %devroot%\swiftshader GOTO skipbuild

@rem Ask to do swiftshader build
@IF %cimode% EQU 0 set /p buildswiftshader=Build SwiftShader (y/n):
@IF %cimode% EQU 1 echo Build SwiftShader (y/n):%buildswiftshader%
@echo.
@IF /I NOT "%buildswiftshader%"=="y" GOTO skipbuild

@rem Get swiftshader source code if missing
@IF %gitstate% GTR 0 IF NOT EXIST %devroot%\swiftshader IF %cimode% EQU 0 (
@git clone https://swiftshader.googlesource.com/SwiftShader %devroot%\swiftshader
@echo.
)
@IF %gitstate% GTR 0 IF NOT EXIST %devroot%\swiftshader IF %cimode% EQU 1 GOTO skipbuild
@cd /d %devroot%\swiftshader

@rem Ask to update source code if git is available
@IF %gitstate% GTR 0 IF %cimode% EQU 0 set /p srcupd=Update SwiftShader source code (y/n):
@IF %gitstate% GTR 0 IF %cimode% EQU 1 echo Update SwiftShader source code (y/n):%srcupd%
@IF %gitstate% GTR 0 echo.
@IF /I "%srcupd%"=="y" git pull -v --progress origin
@IF /I "%srcupd%"=="y" echo.

@IF NOT EXIST build md build
@cd build

@rem Ask if a dry run with collection of build config options and targets is wanted instead of actual build.
@rem Aplies to interactive mode only
@if NOT %ninjastate%==0 IF %cimode% EQU 0 set /p debugbuildscript=Dry run the build only and dump build config options and targets for debugging ^(y/n^)^:
@if NOT %ninjastate%==0 IF %cimode% EQU 0 echo.

@rem Ask for Ninja use if exists. Load it if opted for it.
@if NOT %ninjastate%==0 IF %cimode% EQU 0 if /I NOT "%debugbuildscript%"=="y" set /p ninja=Use Ninja build system instead of MsBuild (y/n); less storage device strain, faster and more efficient build:
@if NOT %ninjastate%==0 IF %cimode% EQU 1 echo Use Ninja build system instead of MsBuild (y/n); less storage device strain, faster and more efficient build:%ninja%
@if NOT %ninjastate%==0 if /I NOT "%debugbuildscript%"=="y" echo.
@if /I "%debugbuildscript%"=="y" set ninja=y
@if /I "%ninja%"=="y" if %ninjastate%==1 set PATH=%devroot%\ninja\;%PATH%

@rem Load cmake into build environment.
@if %cmakestate%==1 set PATH=%devroot%\cmake\bin\;%PATH%

@rem Build configuration.
@set buildconf=cmake -G
@if /I NOT "%ninja%"=="y" set buildconf=%buildconf% "Visual Studio %toolset%"
@if %abi%==x86 if /I NOT "%ninja%"=="y" set buildconf=%buildconf% -A Win32
@if %abi%==x64 if /I NOT "%ninja%"=="y" set buildconf=%buildconf% -A x64
@if /I NOT "%ninja%"=="y" IF /I %PROCESSOR_ARCHITECTURE%==AMD64 set buildconf=%buildconf% -Thost=x64
@if /I "%ninja%"=="y" set buildconf=%buildconf% "Ninja"
@set buildconf=%buildconf% -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../../../%projectname%/dist/%abi% -DSWIFTSHADER_WARNINGS_AS_ERRORS=OFF

@IF %cimode% EQU 0 if /I NOT "%debugbuildscript%"=="y" set /p vk-swiftshader=Build SwiftShader Vulkan Driver - default^:yes (y/n)^:
@IF %cimode% EQU 1 echo Build SwiftShader Vulkan Driver - default^:yes (y/n)^:%vk-swiftshader%
@if /I NOT "%debugbuildscript%"=="y" echo.
@IF /I "%vk-swiftshader%"=="n" set buildconf=%buildconf% -DSWIFTSHADER_BUILD_VULKAN=OFF
@IF /I NOT "%vk-swiftshader%"=="n" set buildconf=%buildconf% -DSWIFTSHADER_BUILD_VULKAN=ON

@IF %cimode% EQU 0 if /I NOT "%debugbuildscript%"=="y" set /p gles-swiftshader=Build SwiftShader GLES Drivers - default^:no (y/n)^:
@IF %cimode% EQU 1 echo Build SwiftShader GLES Drivers - default^:no (y/n)^:%gles-swiftshader%
@if /I NOT "%debugbuildscript%"=="y" echo.
@IF /I "%gles-swiftshader%"=="y" set buildconf=%buildconf% -DSWIFTSHADER_BUILD_EGL=ON -DSWIFTSHADER_BUILD_GLES_CM=ON -DSWIFTSHADER_BUILD_GLESv2=ON
@IF /I NOT "%gles-swiftshader%"=="y" set buildconf=%buildconf% -DSWIFTSHADER_BUILD_EGL=OFF -DSWIFTSHADER_BUILD_GLES_CM=OFF -DSWIFTSHADER_BUILD_GLESv2=OFF

@IF %cimode% EQU 0 if /I NOT "%debugbuildscript%"=="y" set /p subzerojit=Use Subzero JIT instead of LLVM - default^:no (y/n)^:
@IF %cimode% EQU 1 echo Use Subzero JIT instead of LLVM - default^:no (y/n)^:%subzerojit%
@if /I NOT "%debugbuildscript%"=="y" echo.
@IF /I "%subzerojit%"=="y" set buildconf=%buildconf% -DREACTOR_BACKEND=Subzero
@IF /I NOT "%subzerojit%"=="y" set buildconf=%buildconf% -DREACTOR_BACKEND=LLVM

@IF %cimode% EQU 0 if /I NOT "%debugbuildscript%"=="y" IF /I NOT "%subzerojit%"=="y" set /p newllvm=Use new LLVM 10 JIT instead of LLVM 7 - default^:no (y/n)^:
@IF %cimode% EQU 1 IF /I NOT "%subzerojit%"=="y" echo Use new LLVM 10 JIT instead of LLVM 7 - default^:no (y/n)^:%newllvm%
@if /I NOT "%debugbuildscript%"=="y" IF /I NOT "%subzerojit%"=="y" echo.
@IF /I NOT "%newllvm%"=="y" IF /I NOT "%subzerojit%"=="y" set buildconf=%buildconf% -DSWIFTSHADER_LLVM_VERSION=7.0
@IF /I "%newllvm%"=="y" set buildconf=%buildconf% -DSWIFTSHADER_LLVM_VERSION=10.0

@IF /I NOT "%vk-swiftshader%"=="n" IF %cimode% EQU 0 if /I NOT "%debugbuildscript%"=="y" set /p spirvtools=Include SPIRV-Tools in release - default^:yes (y/n)^:
@IF /I NOT "%vk-swiftshader%"=="n" IF %cimode% EQU 1 echo Include SPIRV-Tools in release - default^:yes (y/n)^:%spirvtools%
@IF /I NOT "%vk-swiftshader%"=="n" if /I NOT "%debugbuildscript%"=="y" echo.
@IF /I NOT "%vk-swiftshader%"=="n" IF /I NOT "%spirvtools%"=="n" set buildconf=%buildconf% -DSKIP_SPIRV_TOOLS_INSTALL=OFF
@IF /I NOT "%vk-swiftshader%"=="n" IF /I "%spirvtools%"=="n" set buildconf=%buildconf% -DSKIP_SPIRV_TOOLS_INSTALL=ON

@IF %cimode% EQU 0 if /I NOT "%debugbuildscript%"=="y" set /p test-swiftshader=Build SwiftShader tests - default^:no (y/n)^:
@IF %cimode% EQU 1 echo Build SwiftShader tests - default^:no (y/n)^:%test-swiftshader%
@if /I NOT "%debugbuildscript%"=="y" echo.
@IF /I "%test-swiftshader%"=="y" set buildconf=%buildconf% -DSWIFTSHADER_BUILD_TESTS=ON
@IF /I NOT "%test-swiftshader%"=="y" set buildconf=%buildconf% -DSWIFTSHADER_BUILD_TESTS=OFF

@set buildconf=%buildconf% ..\..

@rem Debug code to get all build options
@if /I "%debugbuildscript%"=="y" set buildconf=cmake -G Ninja -DCMAKE_INSTALL_PREFIX=../../../%projectname%/dist/%abi% -LAH ..\..

@rem Ask if clean build is wanted
@if /I NOT "%debugbuildscript%"=="y" IF %cimode% EQU 0 set /p cleanbuild=Do you want to clean build (y/n):
@IF %cimode% EQU 1 echo Do you want to clean build (y/n):%cleanbuild%
@if /I NOT "%debugbuildscript%"=="y" echo.
@if /I "%debugbuildscript%"=="y" set cleanbuild=y
@IF /I "%cleanbuild%"=="y" echo Cleanning build...
@IF /I "%cleanbuild%"=="y" echo.
@IF /I "%cleanbuild%"=="y" if EXIST buildsys-%abi% RD /S /Q buildsys-%abi%
@IF /I "%cleanbuild%"=="y" if EXIST %devroot%\%projectname%\dist\%abi% RD /S /Q %devroot%\%projectname%\dist\%abi%
@IF NOT EXIST buildsys-%abi% md buildsys-%abi%
@cd buildsys-%abi%

@rem Generate build perform command
@if /I NOT "%ninja%"=="y" if %abi%==x86 set buildcmd=msbuild -p^:Configuration^=release,Platform^=Win32
@if /I NOT "%ninja%"=="y" if %abi%==x64 set buildcmd=msbuild -p^:Configuration^=release,Platform^=x64
@if /I NOT "%ninja%"=="y" IF /I NOT "%spirvtools%"=="n" set buildcmd=%buildcmd% INSTALL.vcxproj
@if /I NOT "%ninja%"=="y" IF /I "%spirvtools%"=="n" set buildcmd=%buildcmd% swiftshader.sln
@if /I NOT "%ninja%"=="y" set buildcmd=%buildcmd% -m^:%throttle% -v^:m
@if /I "%ninja%"=="y" set buildcmd=ninja -j %throttle%
@if /I "%ninja%"=="y" IF /I NOT "%spirvtools%"=="n" set buildcmd=%buildcmd% install
@rem Debug code to list ninja targets.
@if /I "%debugbuildscript%"=="y" set buildcmd=ninja -t targets all

@rem Load Visual Studio environment early when using Ninja. Debugginng build script also requires Ninja so we are covered.
@if /I "%ninja%"=="y" call %vsenv% %vsabi%
@if /I "%ninja%"=="y" echo.

@rem Configure and execute the build with the configuration set above. Create debug file with all build options if wanted.
@echo Build configuration command: %buildconf%
@echo.
@if /I "%debugbuildscript%"=="y" IF NOT EXIST %devroot%\%projectname%\debug md %devroot%\%projectname%\debug
@if /I NOT "%debugbuildscript%"=="y" %buildconf%
@if /I "%debugbuildscript%"=="y" %buildconf% > %devroot%\%projectname%\debug\cmake.txt 2>&1
@echo.
@IF %cimode% EQU 0 pause
@IF %cimode% EQU 0 echo.
@if /I NOT "%ninja%"=="y" call %vsenv% %vsabi%
@if /I NOT "%ninja%"=="y" echo.
@echo Build execution command: %buildcmd%
@echo.
@if /I NOT "%debugbuildscript%"=="y" %buildcmd%
@if /I "%debugbuildscript%"=="y" %buildcmd% > %devroot%\%projectname%\debug\ninja.txt 2>&1
@echo.
@if /I NOT "%debugbuildscript%"=="y" call %devroot%\%projectname%\buildscript\modules\dist.cmd

:skipbuild
@echo.
@rem Reset environment after swiftshader build.
@endlocal
@cd %devroot%
