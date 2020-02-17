@setlocal
@rem Create distribution.
@IF NOT EXIST %devroot%\%projectname%\dist md %devroot%\%projectname%\dist
@IF NOT EXIST %devroot%\%projectname%\dist\%abi% md %devroot%\%projectname%\dist\%abi%
@IF NOT EXIST %devroot%\%projectname%\dist\%abi%\bin md %devroot%\%projectname%\dist\%abi%\bin
@forfiles /p %devroot%\%projectname:~0,-9%\build\buildsys-%abi% /s /m *.dll /c "cmd /c copy @path %devroot%\%projectname%\dist\%abi%\bin"
@forfiles /p %devroot%\%projectname:~0,-9%\build\buildsys-%abi% /s /m *.json /c "cmd /c copy @path %devroot%\%projectname%\dist\%abi%\bin"
@cd /d %devroot%\%projectname%\dist\%abi%\bin
@IF EXIST translator RD /S /Q translator
@md translator
@move *translator.dll translator
@echo.
@endlocal
@cd %devroot%
@IF %cimode% EQU 0 pause