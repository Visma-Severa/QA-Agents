@echo off
:: =============================================================================
:: HealthBridge QA Agents - Update (Windows)
:: =============================================================================
:: Double-click this file to update QA Agents.
:: Works from anywhere - whether at the workspace root or inside setup/ folder.
::
:: This script automatically:
::   - Finds the DEMO-QA-Agents folder
::   - Runs update.ps1 with correct permissions (ExecutionPolicy Bypass)
::   - Keeps the window open so you can see the results
:: =============================================================================

echo.
echo  HealthBridge QA Agents - Update
echo  ==================================
echo.

:: Resolve the directory where this .bat file lives
set "SCRIPT_DIR=%~dp0"

:: Case 1: This .bat is inside setup/ folder (next to update.ps1)
if exist "%SCRIPT_DIR%update.ps1" (
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%update.ps1"
    goto :done
)

:: Case 2: This .bat is at workspace root (copied there by setup)
:: Look for DEMO-QA-Agents\setup\update.ps1
if exist "%SCRIPT_DIR%DEMO-QA-Agents\setup\update.ps1" (
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%DEMO-QA-Agents\setup\update.ps1"
    goto :done
)

:: Could not find update.ps1
echo  ERROR: Could not find update.ps1
echo.
echo  Expected locations:
echo    - %SCRIPT_DIR%update.ps1
echo    - %SCRIPT_DIR%DEMO-QA-Agents\setup\update.ps1
echo.
echo  Make sure the DEMO-QA-Agents repository exists in your workspace.

:done
echo.
pause
