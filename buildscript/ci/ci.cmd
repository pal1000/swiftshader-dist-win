@rem Initialization
@cd "%~dp0"
@cd ..\..\..\
@for %%a in ("%cd%") do @set devroot=%%~sa
@set projectname=swiftshader-dist-win
@IF NOT EXIST %devroot%\%projectname%\dist md %devroot%\%projectname%\dist

@rem Generating build UID
@IF /I %1==updcheck IF NOT EXIST %devroot%\%projectname%\dist\ciasset md %devroot%\%projectname%\dist\ciasset
@IF /I %1==updcheck FOR /F "tokens=*" %%a IN ('type %devroot%\%projectname:~0,-9%\.git\refs\heads\master') do @echo swiftshader-source-code=%%a>%devroot%\%projectname%\dist\ciasset\hashes.ini
@IF /I %1==updcheck FOR /F tokens^=^*^ USEBACKQ^ eol^= %%a IN (`forfiles /p %devroot%\%projectname%\.git\refs\heads /C "cmd /c type @path"`) do @echo swiftshader-dist-win=%%a>>%devroot%\%projectname%\dist\ciasset\hashes.ini
@IF /I %1==updcheck GOTO doneci

@rem Generating version UID and artifact timestamp
@IF NOT EXIST %devroot%\%projectname%\dist\modules md %devroot%\%projectname%\dist\modules
@FOR /F "tokens=* USEBACKQ" %%a IN (`powershell -Command "Get-Date -Format FileDateTimeUniversal"`) do @set artifactuid=%%a
@set artifactver=%artifactuid%
@set artifactuid=%artifactuid:~0,4%-%artifactuid:~4,2%-%artifactuid:~6,2%_%artifactuid:~9,2%-%artifactuid:~11,2%
@set artifactver=%artifactver:~0,8%%artifactver:~9,4%
@echo @set artifactver=%artifactver%>%devroot%\%projectname%\dist\modules\config.cmd
@echo @set reactorbackend=%1>>%devroot%\%projectname%\dist\modules\config.cmd

@rem Run build
@call %devroot%\%projectname%\buildscript\build.cmd x64-%1
@cd %devroot%\%projectname%\dist
@IF EXIST x64\bin\vk_swiftshader_icd.json IF EXIST x64\bin\libEGL.dll IF EXIST x64\bin\vk_swiftshader.dll call %devroot%\%projectname%\buildscript\build.cmd x86-%1
@cd %devroot%\%projectname%\dist
@IF EXIST x64\bin\vk_swiftshader_icd.json IF EXIST x64\bin\libEGL.dll IF EXIST x64\bin\vk_swiftshader.dll IF EXIST x86\bin\vk_swiftshader_icd.json IF EXIST x86\bin\libEGL.dll IF EXIST x86\bin\vk_swiftshader.dll 7z a -t7z -mx=9 ..\swiftshader-%artifactuid%-%1.7z .\*

:doneci
