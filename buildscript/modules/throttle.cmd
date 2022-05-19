@setlocal
@IF %cimode% EQU 0 set "throttle="
@IF %cimode% EQU 0 set /p throttle=Do you want to throttle build. Enter number of parallel jobs. Defaults to %NUMBER_OF_PROCESSORS% which represents the number of your CPU available hyperthreads. You should not enter a value greater than that:
@IF %cimode% EQU 1 echo Do you want to throttle build. Enter number of parallel jobs. Defaults to %NUMBER_OF_PROCESSORS% which represents the number of your CPU available hyperthreads. You should not enter a value greater than that:%throttle%
@echo.
@IF "%throttle%"=="" set throttle=%NUMBER_OF_PROCESSORS%
@IF %throttle% EQU %NUMBER_OF_PROCESSORS% set TITLE=%TITLE% - No CPU Cap
@IF %throttle% NEQ %NUMBER_OF_PROCESSORS% set TITLE=%TITLE% - CPU Cap %throttle%/%NUMBER_OF_PROCESSORS%
@TITLE %TITLE%
@endlocal&set TITLE=%TITLE%&set throttle=%throttle%