@echo off
:: =============================================================================
:: HealthBridge QA Agents - First-Time Setup (Windows)
:: =============================================================================
:: Double-click this file to run the full environment setup.
:: No need to open PowerShell or know any commands.
::
:: This script automatically:
::   - Finds setup.ps1 in the same folder
::   - Runs it with correct permissions (ExecutionPolicy Bypass)
::   - Keeps the window open so you can see the results
:: =============================================================================

echo.
echo  HealthBridge QA Agents - Setup
echo  ================================
echo.

:: Resolve the directory where this .bat file lives
set "SCRIPT_DIR=%~dp0"

:: Check if setup.ps1 exists next to this .bat file
if not exist "%SCRIPT_DIR%setup.ps1" (
    echo  ERROR: setup.ps1 not found in %SCRIPT_DIR%
    echo  Make sure this file is in the setup\ folder of the QA Agents repository.
    echo.
    pause
    exit /b 1
)

:: Run the PowerShell setup script with ExecutionPolicy Bypass
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%setup.ps1"

echo.
pause
