@setlocal
@rem Look for CMake build generator.
@IF %cmakestate%==0 (
@echo Fatal: CMake is required to build swiftshader.
@GOTO skipbuild
)
@IF %gitstate%==0 IF NOT EXIST %devroot%\swiftshader (
@echo Fatal: Failed to obtain swiftshader source code.
@GOTO skipbuild
)

@rem Ask to do swiftshader build
@set /p buildswiftshader=Build SwiftShader (y/n):
@echo.
@IF /I NOT "%buildswiftshader%"=="y" GOTO skipbuild

@rem Get swiftshader source code if missing
@IF %gitstate% GTR 0 IF NOT EXIST %devroot%\swiftshader (
@git clone --recurse-submodules https://github.com/google/swiftshader.git %devroot%\swiftshader
@echo.
)
@cd /d %devroot%\swiftshader
@IF NOT EXIST build md build
@cd build

@rem Ask to update source code if git is available
@IF %gitstate% GTR 0 set /p srcupd=Update SwiftShader source code (y/n):
@IF %gitstate% GTR 0 echo.
@IF /I "%srcupd%"=="y" git pull -v --progress origin
@IF /I "%srcupd%"=="y" echo.
@IF /I "%srcupd%"=="y" git submodule update --init --recursive
@IF /I "%srcupd%"=="y" echo.

@rem Ask for Ninja use if exists. Load it if opted for it.
@if NOT %ninjastate%==0 set /p ninja=Use Ninja build system instead of MsBuild (y/n); less storage device strain, faster and more efficient build:
@if NOT %ninjastate%==0 echo.
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

@set /p vk-swiftshader=Build SwiftShader Vulkan Driver - default^:yes (y/n)^:
@echo.
@IF /I "%vk-swiftshader%"=="n" set buildconf=%buildconf% -DSWIFTSHADER_BUILD_VULKAN=OFF
@IF /I NOT "%vk-swiftshader%"=="n" set buildconf=%buildconf% -DSWIFTSHADER_BUILD_VULKAN=ON

@set /p gles-swiftshader=Build SwiftShader GLES Drivers - default^:no (y/n)^:
@echo.
@IF /I "%gles-swiftshader%"=="y" set buildconf=%buildconf% -DSWIFTSHADER_BUILD_EGL=ON -DSWIFTSHADER_BUILD_GLES_CM=ON -DSWIFTSHADER_BUILD_GLESv2=ON
@IF /I NOT "%gles-swiftshader%"=="y" set buildconf=%buildconf% -DSWIFTSHADER_BUILD_EGL=OFF -DSWIFTSHADER_BUILD_GLES_CM=OFF -DSWIFTSHADER_BUILD_GLESv2=OFF

@set /p subzerojit=Use Subzero JIT instead of LLVM - default^:no (y/n)^:
@echo.
@IF /I "%subzerojit%"=="y" set buildconf=%buildconf% -DREACTOR_BACKEND=Subzero
@IF /I NOT "%subzerojit%"=="y" set buildconf=%buildconf% -DREACTOR_BACKEND=LLVM

@set /p test-swiftshader=Build SwiftShader tests and samples - default^:no (y/n)^:
@echo.
@IF /I "%test-swiftshader%"=="y" set buildconf=%buildconf% -DSWIFTSHADER_BUILD_SAMPLES=ON -DSWIFTSHADER_BUILD_TESTS=ON
@IF /I NOT "%test-swiftshader%"=="y" set buildconf=%buildconf% -DSWIFTSHADER_BUILD_SAMPLES=OFF -DSWIFTSHADER_BUILD_TESTS=OFF

@set buildconf=%buildconf% ..\..
@rem set buildconf=cmake -G Ninja -DCMAKE_INSTALL_PREFIX=../../../%projectname%/dist/%abi% -LAH ..\..

@rem Ask if clean build is wanted
@set /p cleanbuild=Do you want to clean build (y/n):
@echo.
@IF /I "%cleanbuild%"=="y" (
@echo Cleanning build...
@echo.
@if EXIST buildsys-%abi% RD /S /Q buildsys-%abi%
@if EXIST %devroot%\%projectname%\dist\%abi% RD /S /Q %devroot%\%projectname%\dist\%abi%
)
@IF NOT EXIST buildsys-%abi% md buildsys-%abi%
@cd buildsys-%abi%

@rem Load Visual Studio environment early when using Ninja.
@if /I "%ninja%"=="y" call %vsenv% %vsabi%
@if /I "%ninja%"=="y" echo.

@rem Configure and execute the build with the configuration made above.
@echo Build configuration command: %buildconf%
@echo.
@IF NOT EXIST %devroot%\%projectname%\debug md %devroot%\%projectname%\debug
@%buildconf%
@rem %buildconf% > %devroot%\%projectname%\debug\cmake.txt 2>&1
@echo.
@pause
@echo.
@if /I NOT "%ninja%"=="y" call %vsenv% %vsabi%
@if /I NOT "%ninja%"=="y" echo.
@if /I NOT "%ninja%"=="y" if %abi%==x86 msbuild /p^:Configuration=release,Platform=Win32 INSTALL.vcxproj /m^:%throttle%
@if /I NOT "%ninja%"=="y" if %abi%==x64 msbuild /p^:Configuration=release,Platform=x64 INSTALL.vcxproj /m^:%throttle%
@if /I "%ninja%"=="y" ninja -j %throttle% install
@rem if /I "%ninja%"=="y" ninja -t targets all > %devroot%\%projectname%\debug\ninja.txt 2>&1

:skipbuild
@echo.
@rem Reset environment after swiftshader build.
@endlocal
@cd %devroot%