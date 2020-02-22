@set devroot=c:\projects
@set projectname=swiftshader-dist-win

@IF /I %cijob%==init GOTO appveyor-init
@IF /I %cijob%==artifact-llvm GOTO artifact-llvm
@IF /I %cijob%==artifact-subzero GOTO artifact-subzero
@IF /I %cijob:~0,1%==x GOTO run-build

:appveyor-init
@rem Clean leftover binaries and build info data
@IF EXIST %devroot%\%projectname%\dist\buildinfo RD /S /Q %devroot%\%projectname%\dist\buildinfo
@IF EXIST %devroot%\%projectname%\dist\x??\ RD /S /Q %devroot%\%projectname%\dist\x??
@rem Get swiftshader source code
@git clone -q -n https://github.com/google/%projectname:~0,-9% %devroot%\%projectname:~0,-9%
@rem Get / update build script source
@IF NOT EXIST %devroot%\%projectname% (
@set firstbuild=1
@git clone -q --branch=master https://github.com/%APPVEYOR_ACCOUNT_NAME%/%projectname% %devroot%\%projectname%
)
@cd %devroot%\%projectname%
@IF NOT defined firstbuild (
@git checkout master
@git pull
)
@git checkout %1
@rem Configure build title
@cd %devroot%\%projectname:~0,-9%
@type %devroot%\%projectname%\buildscript\ci\appveyor.ps1 | powershell -NoLogo >nul 2>&1
@rem Save swiftshader commit ID, build start timestamp and its converted form into a version string
@FOR /F "tokens=* USEBACKQ" %%a IN (`powershell -Command "Get-Date -Format FileDateTimeUniversal"`) do @set artifactuid=%%a
@set artifactver=%artifactuid%
@set artifactuid=%artifactuid:~0,4%-%artifactuid:~4,2%-%artifactuid:~6,2%_%artifactuid:~9,2%-%artifactuid:~11,2%
@set artifactver=%artifactver:~0,8%%artifactver:~9,4%
@IF NOT EXIST %devroot%\%projectname%\dist md %devroot%\%projectname%\dist
@IF NOT EXIST %devroot%\%projectname%\dist\modules md %devroot%\%projectname%\dist\modules
@echo @set artifactuid=%artifactuid%>%devroot%\%projectname%\dist\modules\uid.cmd
@echo @set artifactver=%artifactver%>>%devroot%\%projectname%\dist\modules\uid.cmd
@FOR /F "tokens=*" %%a IN ('type %devroot%\%projectname:~0,-9%\.git\refs\heads\master') do @echo @set swiftshadercommit=%%a>>%devroot%\%projectname%\dist\modules\uid.cmd
@GOTO doneappveyor

:run-build
@type %devroot%\%projectname%\dist\modules\uid.cmd
@GOTO doneappveyor

:artifact-llvm
@GOTO doneappveyor

:artifact-subzero
@GOTO doneappveyor

c:\projects\swiftshader-dist-win\buildscript\ci\init.cmd
@IF NOT %cijob%==init IF NOT %cijob%==artifact-LLVM IF NOT %cijob%==artifact-subzero c:\projects\swiftshader-dist-win\buildscript\build.cmd %cijob%
@IF %cijob%==x86-llvm c:\projects\swiftshader-dist-win\buildscript\build.cmd %cijob%
cd c:\projects\swiftshader-dist-win\dist
IF EXIST x86\bin\libEGL.dll IF EXIST x64\bin\libEGL.dll IF EXIST x86\bin\vk_swiftshader.dll IF EXIST x64\bin\vk_swiftshader.dll IF EXIST x86\bin\vk_swiftshader_icd.json IF EXIST x64\bin\vk_swiftshader_icd.json 7z a ..\swiftshader-%artifactuid%-LLVM.zip .\*
IF EXIST c:\projects\swiftshader-dist-win\swiftshader-%artifactuid%-LLVM.zip appveyor PushArtifact c:\projects\swiftshader-dist-win\swiftshader-%artifactuid%-LLVM.zip
@IF %cijob%==x64-subzero c:\projects\swiftshader-dist-win\buildscript\build.cmd %cijob%
@IF %cijob%==x86-subzero c:\projects\swiftshader-dist-win\buildscript\build.cmd %cijob%
cd c:\projects\swiftshader-dist-win\dist
IF EXIST x86\bin\libEGL.dll IF EXIST x64\bin\libEGL.dll IF EXIST x86\bin\vk_swiftshader.dll IF EXIST x64\bin\vk_swiftshader.dll IF EXIST x86\bin\vk_swiftshader_icd.json IF EXIST x64\bin\vk_swiftshader_icd.json 7z a ..\swiftshader-%artifactuid%-subzero.zip .\*
IF EXIST c:\projects\swiftshader-dist-win\swiftshader-%artifactuid%-subzero.zip appveyor PushArtifact c:\projects\swiftshader-dist-win\swiftshader-%artifactuid%-subzero.zip

:doneappveyor