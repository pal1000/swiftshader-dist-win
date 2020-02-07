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
@set /p buildswiftshader=Build SwiftShader Vulkan driver (y/n):
@echo.
@IF /I NOT "%buildswiftshader%"=="y" GOTO skipbuild

@rem Get swiftshader source code if missing
@IF %gitstate% GTR 0 IF NOT EXIST %devroot%\swiftshader (
@git clone --recurse-submodules https://github.com/google/swiftshader.git %devroot%\swiftshader
@echo.
)
@cd /d %devroot%\swiftshader
@IF %gitstate% GTR 0 (
@git pull -v --progress origin
@echo.
@git submodule update --init --recursive
@echo.
)

@rem Ask for Ninja use if exists. Load it if opted for it.
@set ninja=n
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
@set buildconf=%buildconf% -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../%abi% ..

@rem Ask if clean build is wanted
@echo Removing binaries...
@echo.
@if EXIST %abi% RD /S /Q %abi%
@set cleanbuild=n
@set /p cleanbuild=Do you want to clean build (y/n):
@echo.
@IF /I "%cleanbuild%"=="y" (
@echo Cleanning build system...
@echo.
@if EXIST buildsys-%abi% RD /S /Q buildsys-%abi%
)
@IF NOT EXIST buildsys-%abi% md buildsys-%abi%
@cd buildsys-%abi%

@rem Load Visual Studio environment early when using Ninja.
@if /I "%ninja%"=="y" call %vsenv% %vsabi%
@if /I "%ninja%"=="y" echo.

@rem Configure and execute the build with the configuration made above.
@%buildconf%
@echo.
@pause
@echo.
@if /I NOT "%ninja%"=="y" call %vsenv% %vsabi%
@if /I NOT "%ninja%"=="y" echo.
@if /I NOT "%ninja%"=="y" if %abi%==x86 msbuild /p^:Configuration=release,Platform=Win32 vk_swiftshader.vcxproj /m^:%throttle%
@if /I NOT "%ninja%"=="y" if %abi%==x64 msbuild /p^:Configuration=release,Platform=x64 vk_swiftshader.vcxproj /m^:%throttle%
@if /I "%ninja%"=="y" ninja -j %throttle% vk_swiftshader

:skipbuild
@echo.
@rem Reset environment after swiftshader build.
@endlocal
@cd %devroot%