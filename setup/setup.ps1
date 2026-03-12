# =============================================================================
# HealthBridge QA Agents - Full Environment Setup (Windows PowerShell)
# =============================================================================
# This script sets up the complete multi-repository workspace:
#   1. Clones all repositories (skips existing ones)
#   2. Copies workspace file and AI configuration files
#   3. Sets up .claude/ directory with CLAUDE.md
#   4. Builds and installs the VS Code chat extension
#
# Usage:
#   .\setup\setup.ps1                       # Run from QA Agents repo
#   .\setup\setup.ps1 -TargetDir "C:\Work"  # Specify workspace parent directory
# =============================================================================

param(
    [string]$TargetDir
)

$ErrorActionPreference = "Stop"

# --- Resolve paths dynamically ---
$ScriptDir = $PSScriptRoot
$QaAgentsDir = (Resolve-Path "$ScriptDir\..").Path
if ($TargetDir) {
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }
    $WorkspaceRoot = (Resolve-Path $TargetDir).Path
} else {
    $WorkspaceRoot = (Resolve-Path "$QaAgentsDir\..").Path
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Blue
Write-Host " HealthBridge QA Agents - Environment Setup" -ForegroundColor Blue
Write-Host "=============================================" -ForegroundColor Blue
Write-Host ""
Write-Host "Workspace root: " -NoNewline; Write-Host $WorkspaceRoot -ForegroundColor White
Write-Host "QA Agents repo: " -NoNewline; Write-Host $QaAgentsDir -ForegroundColor White
Write-Host ""

# --- Helper functions ---
function Print-Step($StepNum, $TotalSteps, $Message) {
    Write-Host "[Step $StepNum/$TotalSteps] " -ForegroundColor Blue -NoNewline
    Write-Host $Message -ForegroundColor White
}

function Print-Ok($Message) {
    Write-Host "  OK " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Print-Skip($Message) {
    Write-Host "  SKIP " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Print-Fail($Message) {
    Write-Host "  FAIL " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

$TotalSteps = 6

# =============================================================================
# Step 1: Clone all repositories
# =============================================================================
Print-Step 1 $TotalSteps "Cloning repositories"
Write-Host ""

# Each entry: "repo-name=clone-url"
$Repos = @(
    # Core application repositories
    "HealthBridge-Web=https://github.com/healthbridge-org/HealthBridge-Web.git",
    "HealthBridge-Portal=https://github.com/healthbridge-org/HealthBridge-Portal.git",
    "HealthBridge-Api=https://github.com/healthbridge-org/HealthBridge-Api.git",
    "HealthBridge-Mobile=https://github.com/healthbridge-org/HealthBridge-Mobile.git",
    # Microservice API repositories
    "HealthBridge-Claims-Processing=https://github.com/healthbridge-org/HealthBridge-Claims-Processing.git",
    "HealthBridge-Prescriptions-Api=https://github.com/healthbridge-org/HealthBridge-Prescriptions-Api.git",
    # Test automation repositories
    "HealthBridge-Selenium-Tests=https://github.com/healthbridge-org/HealthBridge-Selenium-Tests.git",
    "HealthBridge-E2E-Tests=https://github.com/healthbridge-org/HealthBridge-E2E-Tests.git",
    "HealthBridge-Mobile-Tests=https://github.com/healthbridge-org/HealthBridge-Mobile-Tests.git"
)

$Cloned = 0
$Skipped = 0

foreach ($Entry in $Repos) {
    $Parts = $Entry -split "=", 2
    $Repo = $Parts[0]
    $Url = $Parts[1]
    $Target = Join-Path $WorkspaceRoot $Repo
    if (Test-Path $Target) {
        Print-Skip "$Repo (already exists)"
        $Skipped++
    } else {
        Write-Host "  Cloning $Repo..."
        try {
            git clone $Url "$Target" 2>$null
            Print-Ok $Repo
            $Cloned++
        } catch {
            Print-Fail "$Repo (clone failed - check access)"
        }
    }
}

Write-Host ""
Write-Host "  Cloned: " -NoNewline; Write-Host $Cloned -ForegroundColor Green -NoNewline
Write-Host " | Skipped: " -NoNewline; Write-Host $Skipped -ForegroundColor Yellow
Write-Host ""

# =============================================================================
# Step 2: Copy workspace file
# =============================================================================
Print-Step 2 $TotalSteps "Copying workspace file"

$WorkspaceFile = Join-Path $QaAgentsDir "HealthBridge.code-workspace"
$TargetWorkspace = Join-Path $WorkspaceRoot "HealthBridge.code-workspace"

if (Test-Path $WorkspaceFile) {
    Copy-Item -Path $WorkspaceFile -Destination $TargetWorkspace -Force
    Print-Ok "HealthBridge.code-workspace copied to workspace root"
} else {
    Print-Fail "HealthBridge.code-workspace not found in QA Agents repo"
}

# Copy update.bat to workspace root (double-clickable updater)
$UpdateBatSrc = Join-Path $QaAgentsDir "setup\update.bat"
$UpdateBatDst = Join-Path $WorkspaceRoot "update.bat"

if (Test-Path $UpdateBatSrc) {
    Copy-Item -Path $UpdateBatSrc -Destination $UpdateBatDst -Force
    Print-Ok "update.bat copied to workspace root (double-click to update)"
} else {
    Print-Skip "update.bat not found in setup/"
}
Write-Host ""

# =============================================================================
# Step 3: Copy AI configuration files
# =============================================================================
Print-Step 3 $TotalSteps "Copying AI configuration files"

# Copilot instructions
$CopilotSrc = Join-Path $QaAgentsDir ".github\copilot-instructions.md"
$CopilotDst = Join-Path $WorkspaceRoot ".github\copilot-instructions.md"

if (Test-Path $CopilotSrc) {
    New-Item -ItemType Directory -Path (Join-Path $WorkspaceRoot ".github") -Force | Out-Null
    Copy-Item -Path $CopilotSrc -Destination $CopilotDst -Force
    Print-Ok ".github\copilot-instructions.md"
} else {
    Print-Skip ".github\copilot-instructions.md (source not found)"
}

# Cursor rules
$CursorSrc = Join-Path $QaAgentsDir ".cursorrules"
$CursorDst = Join-Path $WorkspaceRoot ".cursorrules"

if (Test-Path $CursorSrc) {
    Copy-Item -Path $CursorSrc -Destination $CursorDst -Force
    Print-Ok ".cursorrules"
} else {
    Print-Skip ".cursorrules (source not found)"
}

# Claude Code instructions
$ClaudeSrc = Join-Path $QaAgentsDir ".claude\CLAUDE.md"
$ClaudeDst = Join-Path $WorkspaceRoot ".claude\CLAUDE.md"

if (Test-Path $ClaudeSrc) {
    New-Item -ItemType Directory -Path (Join-Path $WorkspaceRoot ".claude") -Force | Out-Null
    Copy-Item -Path $ClaudeSrc -Destination $ClaudeDst -Force
    Print-Ok ".claude\CLAUDE.md"
} elseif (Test-Path $ClaudeDst) {
    Print-Skip ".claude\CLAUDE.md (already exists)"
} else {
    Print-Skip ".claude\CLAUDE.md (source not found in QA Agents repo)"
}
Write-Host ""

# =============================================================================
# Step 4: Create reports directories
# =============================================================================
Print-Step 4 $TotalSteps "Creating reports directories"

$ReportsDir = Join-Path $QaAgentsDir "reports"
$ReportSubdirs = @(
    "code-review",
    "acceptance-tests",
    "bug-reports",
    "bugfix-rca",
    "requirements-analysis",
    "week-release",
    "feedback",
    "dev-estimation",
    "qa-test-plan"
)

foreach ($Subdir in $ReportSubdirs) {
    New-Item -ItemType Directory -Path (Join-Path $ReportsDir $Subdir) -Force | Out-Null
}
Print-Ok "reports\ with $($ReportSubdirs.Count) subdirectories"
Write-Host ""

# =============================================================================
# Step 5: Build and install VS Code extension
# =============================================================================
Print-Step 5 $TotalSteps "Building and installing VS Code extension"

$ExtDir = Join-Path $QaAgentsDir ".vscode-extension"

if (-not (Test-Path $ExtDir)) {
    Print-Fail ".vscode-extension directory not found"
    Write-Host ""
} else {
    # Check for Node.js
    $NodeExists = Get-Command node -ErrorAction SilentlyContinue
    $NpmExists = Get-Command npm -ErrorAction SilentlyContinue

    if (-not $NodeExists) {
        Print-Fail "Node.js is not installed. Install it from https://nodejs.org/"
        Write-Host ""
    } elseif (-not $NpmExists) {
        Print-Fail "npm is not installed. Install Node.js from https://nodejs.org/"
        Write-Host ""
    } else {
        Push-Location $ExtDir

        Write-Host "  Installing dependencies..."
        npm install --silent 2>$null
        Print-Ok "npm install"

        Write-Host "  Compiling extension..."
        npm run compile --silent 2>$null
        Print-Ok "npm run compile"

        Write-Host "  Packaging extension..."
        cmd /c "npx vsce package --allow-missing-repository 2>nul"
        Print-Ok "vsce package"

        # Find the generated VSIX file
        $VsixFile = Get-ChildItem -Path $ExtDir -Filter "*.vsix" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

        if (-not $VsixFile) {
            Print-Fail "No .vsix file found after packaging"
        } else {
            Write-Host "  Installing extension..."
            $CodeExists = Get-Command code -ErrorAction SilentlyContinue
            if ($CodeExists) {
                cmd /c "code --install-extension `"$($VsixFile.FullName)`" --force 2>nul"
                Print-Ok "Extension installed via 'code' CLI"
            } else {
                Print-Fail "VS Code CLI not found"
                Write-Host "  Install manually: code --install-extension $($VsixFile.FullName) --force" -ForegroundColor Yellow
            }
        }

        Pop-Location
        Write-Host ""
    }
}

# =============================================================================
# Step 6: Summary and next steps
# =============================================================================
Print-Step 6 $TotalSteps "Setup complete"
Write-Host ""

Write-Host "=============================================" -ForegroundColor Green
Write-Host " Setup Complete!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Workspace: " -NoNewline; Write-Host $WorkspaceRoot
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Open the workspace in VS Code:"
Write-Host "     code $TargetWorkspace" -ForegroundColor Blue
Write-Host ""
Write-Host "  2. Reload VS Code (F1 > 'Developer: Reload Window')"
Write-Host ""
Write-Host "  3. Verify agents: type @hb in GitHub Copilot Chat"
Write-Host ""
Write-Host "To update the extension later:" -ForegroundColor White
Write-Host "     .\setup\update-extension.ps1" -ForegroundColor Blue
Write-Host ""
