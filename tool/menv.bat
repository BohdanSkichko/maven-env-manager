@echo off

rem Check if PowerShell is installed
where /q pwsh
IF ERRORLEVEL 1 (
    where /q powershell
    IF ERRORLEVEL 1 (
        echo Neither pwsh.exe nor powershell.exe was found in your path.
        echo Please install PowerShell. It is required.
        exit /B
    ) ELSE (
        set "ps=powershell"
    )
) ELSE (
    set "ps=pwsh"
)

rem Run the mvenv PowerShell script with arguments
%ps% -executionpolicy remotesigned -File "%~dp0\src\MEnv.ps1" %* --output

if exist menv.home.tmp (
    FOR /F "tokens=* delims=" %%x in (menv.home.tmp) DO (
        set MAVEN_HOME=%%x
    )
    del -f menv.home.tmp
)

if exist menv.path.tmp (
    FOR /F "tokens=* delims=" %%x in (menv.path.tmp) DO (
        set path=%%x
    )
    del -f menv.path.tmp
)

