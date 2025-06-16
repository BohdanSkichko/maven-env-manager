@echo off
for /f "delims=" %%i in ('menv getmvn') do set "var=%%i"

if exist "%var%/bin/mvn.cmd" (
    "%var%/bin/mvn.cmd" %*
) else (
    echo There was an error:
    echo %var%
)