@echo off
chcp 65001 >nul

REM Check admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: Administrator privileges required.
    pause
    exit /b 1
)

echo Stopping WinDivert service...
sc stop WinDivert >nul 2>&1
timeout /t 2 /nobreak >nul

echo Deleting WinDivert service...
sc delete WinDivert >nul 2>&1

if %errorLevel% equ 0 (
    echo Success: Service deleted.
) else (
    echo Error: Service not found or delete failed. Error code: %errorLevel%
)

pause
