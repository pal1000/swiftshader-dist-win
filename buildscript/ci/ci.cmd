@rem Initialization
@cd "%~dp0"
@cd ..\..\..\
@for %%a in ("%cd%") do @set devroot=%%~sa
@set projectname=swiftshader-dist-win

@rem Determine if new build is needed
@IF EXIST %devroot%\%projectname%\buildscript\ci\assets REN %devroot%\%projectname%\buildscript\ci\assets %devroot%\%projectname%\buildscript\ci\assets-old
@md %devroot%\%projectname%\buildscript\ci\assets
@cd %devroot%\%projectname:~0,-9%
@FOR /F "tokens=*" %%a IN ('git rev-parse HEAD') do @echo swiftshader-source-code=%%a>%devroot%\%projectname%\buildscript\ci\assets\hashes.ini
@cd %devroot%\%projectname%
@FOR /F "tokens=*" %%a IN ('git rev-parse HEAD') do @echo swiftshader-dist-win=%%a>>%devroot%\%projectname%\buildscript\ci\assets\hashes.ini
@echo ---------------------------------------------------------
@echo Diagnostic data to check if skip build support is viable.
@echo ---------------------------------------------------------
@echo Current build UIDs
@echo ------------------
@type %devroot%\%projectname%\buildscript\ci\assets\hashes.ini
@echo -------------------
@echo Previous build UIDs
@echo -------------------
@IF EXIST %devroot%\%projectname%\buildscript\ci\assets-old\hashes.ini type %devroot%\%projectname%\buildscript\ci\assets-old\hashes.ini
@IF NOT EXIST %devroot%\%projectname%\buildscript\ci\assets-old\hashes.ini echo File not found - %devroot%\%projectname%\buildscript\ci\assets-old\hashes.ini. No previous build data available. Skip build support is disabled.
@FC /B %devroot%\%projectname%\buildscript\ci\assets-old\hashes.ini %devroot%\%projectname%\buildscript\ci\assets\hashes.ini>NUL 2>&1 &&GOTO doneci
@cd %devroot%

@rem Generating version UID and artifact timestamp
@IF NOT EXIST %devroot%\%projectname%\dist md %devroot%\%projectname%\dist
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
@cd %devroot%