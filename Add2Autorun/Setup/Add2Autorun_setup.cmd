@echo off
setlocal


:Main: "args="
:: Some initialization work
call :Initialize
call :PrintHeader

:: First argument required
set "setupSwitch=%~1"
set "adminSwitch=%~2"
if not defined setupSwitch (
    call :PrintUsage
    call :PrintFooter "Aborted."
    call :Exit
)

:: Check admin rights
call :IsElevatedCMD
if not "%errorlevel%"=="0" (
    if "%adminSwitch%"=="/uac" (
        call :PrintFooter "Failed to elevate CMD."
        call :Exit
    ) else (
        call :PrintFooter "Elevating..."
        call :RestartWithUAC "%setupSwitch%"
    )
)

:: Determine framework root
set "regasmDirectory=%SystemRoot%\Microsoft.NET\Framework"
call :Is32bitOS
if not "%errorlevel%"=="0" (
    set "regasmDirectory=%regasmDirectory%64"
)
set "regasmDirectory=%regasmDirectory%\v4.0.30319"

:: Setup Add2Autorun server
if "%setupSwitch%"=="/install" (
    "%regasmDirectory%\regasm.exe" /codebase "%~dp0\Add2Autorun.dll" >nul 2>&1
    set "isArgumentValid=true"
)
if "%setupSwitch%"=="/uninstall" (
    "%regasmDirectory%\regasm.exe" /unregister "%~dp0\Add2Autorun.dll" >nul 2>&1
    set "isArgumentValid=true"
)
if not defined isArgumentValid (
    call :PrintUsage
    call :PrintFooter "Aborted."
    call :Exit
)

call :PrintFooter "Done!"
call :Exit

exit


:: PRIVATE

:PrintHeader: ""
echo #######################################################
echo ##        Add2Autorun Shell Extension Setup          ##
echo #######################################################
exit /b

:PrintUsage: ""
echo Usage: %~n0 /install
echo Usage: %~n0 /uninstall
echo.
exit /b

:PrintFooter: "message"
echo %~1
echo.
echo /-------------------------------------------------------------------\
echo  Fork me on GitHub: https://github.com/Svetomech/Add2Autorun
echo \-------------------------------------------------------------------/
exit /b

:: PUBLIC

:Initialize: ""
title %~n0
color 07
cls
chdir /d "%~dp0"
exit /b

:Is32bitOS: ""
set "errorlevel=0"
reg query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" >nul 2>&1 || set "errorlevel=1"
exit /b %errorlevel%

:IsElevatedCMD: ""
set "errorlevel=0"
net session >nul 2>&1 || set "errorlevel=1"
exit /b %errorlevel%

:RestartWithUAC: "args="
set "_helperPath=%temp%\%~n0.helper-%random%.vbs"
echo Set UAC = CreateObject^("Shell.Application"^) > "%_helperPath%"
echo UAC.ShellExecute "%~f0", "%~1 /uac", "", "runas", 1 >> "%_helperPath%"
cscript "%_helperPath%" //b //nologo >nul 2>&1
erase /f /s /q /a "%_helperPath%" >nul 2>&1
set "_helperPath="
exit

:Exit: ""
timeout /t 2 /nobreak >nul 2>&1
exit
