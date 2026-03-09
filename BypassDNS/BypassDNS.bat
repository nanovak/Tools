@echo off
setlocal

NET SESSION >NUL 2>&1
if %errorlevel% neq 0 (
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~f0' -Verb RunAs"
  exit /b
)

set "SCRIPT=%~dp0BypassDns.ps1"

echo.
echo ===========================
echo   DNS Quick Tool (Admin)
echo ===========================
echo 1) Set DNS to 4.2.2.2, 4.2.2.1
echo 2) Revert DNS to DHCP
echo.

choice /c 12 /n /m "Choose 1 or 2: "
if errorlevel 2 goto DHCP
if errorlevel 1 goto STATIC

:STATIC
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -Mode SetStatic
goto END

:DHCP
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -Mode SetDhcp
goto END

:END
echo.
echo Done. Press any key to close...
pause >nul
``