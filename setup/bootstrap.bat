@echo off
:: =============================================================================
:: QA Agents Framework — Bootstrap (Windows)
:: =============================================================================
:: Double-click this file to create a new QA Agents project from the DEMO.
:: You will be prompted for a project name.
:: =============================================================================

echo.
echo  QA Agents Framework - Bootstrap
echo  ================================
echo.

:: Resolve the directory where this .bat file lives
set "SCRIPT_DIR=%~dp0"

:: Check if bootstrap.ps1 exists next to this .bat file
if not exist "%SCRIPT_DIR%bootstrap.ps1" (
    echo  ERROR: bootstrap.ps1 not found in %SCRIPT_DIR%
    echo  Make sure this file is in the setup\ folder of the QA Agents repository.
    echo.
    pause
    exit /b 1
)

:: Prompt for project name
set /p PROJECT_NAME="  Enter your project name (e.g., Falcon, Acme Platform): "

if "%PROJECT_NAME%"=="" (
    echo.
    echo  ERROR: Project name cannot be empty.
    echo.
    pause
    exit /b 1
)

:: Run the PowerShell bootstrap script
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%bootstrap.ps1" -ProjectName "%PROJECT_NAME%"

echo.
pause
