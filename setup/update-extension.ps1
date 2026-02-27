# =============================================================================
# HealthBridge QA Agents - Update VS Code Extension (Windows PowerShell)
# =============================================================================
# Rebuilds and reinstalls the VS Code chat extension after pulling changes.
#
# Usage:
#   .\setup\update-extension.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

# --- Resolve paths dynamically ---
$ScriptDir = $PSScriptRoot
$QaAgentsDir = (Resolve-Path "$ScriptDir\..").Path
$ExtDir = Join-Path $QaAgentsDir ".vscode-extension"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Blue
Write-Host " HealthBridge QA Agents - Extension Update" -ForegroundColor Blue
Write-Host "=============================================" -ForegroundColor Blue
Write-Host ""

# --- Validate ---
if (-not (Test-Path $ExtDir)) {
    Write-Host "Error: .vscode-extension directory not found at:" -ForegroundColor Red
    Write-Host "  $ExtDir"
    exit 1
}

$NodeExists = Get-Command node -ErrorAction SilentlyContinue
if (-not $NodeExists) {
    Write-Host "Error: Node.js is not installed. Install it from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

Push-Location $ExtDir

# --- Step 1: Install dependencies ---
Write-Host "[1/4] " -ForegroundColor Blue -NoNewline
Write-Host "Installing dependencies..."
npm install --silent 2>$null
Write-Host "  OK " -ForegroundColor Green -NoNewline
Write-Host "npm install"

# --- Step 2: Compile ---
Write-Host "[2/4] " -ForegroundColor Blue -NoNewline
Write-Host "Compiling extension..."
npm run compile --silent 2>$null
Write-Host "  OK " -ForegroundColor Green -NoNewline
Write-Host "npm run compile"

# --- Step 3: Package ---
Write-Host "[3/4] " -ForegroundColor Blue -NoNewline
Write-Host "Packaging extension..."
cmd /c "npx vsce package --allow-missing-repository 2>nul"
Write-Host "  OK " -ForegroundColor Green -NoNewline
Write-Host "vsce package"

# --- Step 4: Install ---
Write-Host "[4/4] " -ForegroundColor Blue -NoNewline
Write-Host "Installing extension..."

$VsixFile = Get-ChildItem -Path $ExtDir -Filter "*.vsix" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $VsixFile) {
    Write-Host "  FAIL " -ForegroundColor Red -NoNewline
    Write-Host "No .vsix file found after packaging"
    Pop-Location
    exit 1
}

$CodeExists = Get-Command code -ErrorAction SilentlyContinue
if ($CodeExists) {
    cmd /c "code --install-extension `"$($VsixFile.FullName)`" --force 2>nul"
    Write-Host "  OK " -ForegroundColor Green -NoNewline
    Write-Host "Extension installed via 'code' CLI"
} else {
    Write-Host "  FAIL " -ForegroundColor Red -NoNewline
    Write-Host "VS Code CLI not found"
    Write-Host "  Install manually: code --install-extension $($VsixFile.FullName) --force" -ForegroundColor Yellow
    Pop-Location
    exit 1
}

Pop-Location

Write-Host ""
Write-Host "Extension updated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Reload VS Code to activate: F1 > 'Developer: Reload Window'" -ForegroundColor Blue
Write-Host ""
