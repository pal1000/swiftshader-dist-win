@setlocal
@rem Create distribution.
@IF NOT EXIST %devroot%\%projectname%\dist md %devroot%\%projectname%\dist
@IF NOT EXIST %devroot%\%projectname%\dist\%abi% md %devroot%\%projectname%\dist\%abi%
@IF NOT EXIST %devroot%\%projectname%\dist\%abi%\bin md %devroot%\%projectname%\dist\%abi%\bin
@forfiles /p %devroot%\%projectname:~0,-9%\build\buildsys-%abi% /s /m *.dll /c "cmd /c copy @path %devroot%\%projectname%\dist\%abi%\bin"
@forfiles /p %devroot%\%projectname:~0,-9%\build\buildsys-%abi% /s /m *.json /c "cmd /c copy @path %devroot%\%projectname%\dist\%abi%\bin"
@cd /d %devroot%\%projectname%\dist\%abi%\bin
@IF EXIST translator RD /S /Q translator
@IF EXIST *translator.dll md translator
@IF EXIST *translator.dll move *translator.dll translator
@IF EXIST libEGL_deprecated.dll REN libEGL_deprecated.dll libEGL.dll
@IF EXIST libGLESv2_deprecated.dll REN libGLESv2_deprecated.dll libGLESv2.dll
@echo.
@endlocal
@cd %devroot%
@IF %cimode% EQU 0 pause
@IF %cimode% EQU 0 echo.