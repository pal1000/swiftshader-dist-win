@setlocal
@rem Create distribution.
@if NOT EXIST %devroot%\%projectname:~0,-9%\build\buildsys-%abi% GOTO exit
@set /p dist=Create or update distribution package (y/n):
@echo.
@if /I NOT "%dist%"=="y" GOTO exit
@cd %devroot%

@forfiles /p %devroot%\%projectname:~0,-9%\build\buildsys-%abi% /s /m *.dll /c "cmd /c copy @path %devroot%\%projectname%\dist\%abi%\bin"
@forfiles /p %devroot%\%projectname:~0,-9%\build\buildsys-%abi% /s /m *.json /c "cmd /c copy @path %devroot%\%projectname%\dist\%abi%\bin"
@cd /d %devroot%\%projectname%\dist\%abi%\bin
@IF NOT EXIST translator md translator
@move lib*.dll translator
@move translator\libEGL.dll .
@move translator\libGLESv2.dll .
@move translator\libGLES*.dll .
@echo.

:exit
@endlocal
@cd %devroot%
@pause
@exit