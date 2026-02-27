# =============================================================================
# HealthBridge QA Agents - Update (Windows PowerShell)
# =============================================================================
# Single command to update everything after the QA Agents repo has new changes:
#   1. Pulls latest changes (git pull)
#   2. Syncs AI config files to workspace root
#   3. Rebuilds and reinstalls VS Code chat extension
#
# Usage:
#   .\setup\update.ps1                # Full update (pull + config + extension)
#   .\setup\update.ps1 -NoPull        # Skip git pull
#   .\setup\update.ps1 -NoExtension   # Skip VS Code extension rebuild
# =============================================================================

param(
    [switch]$NoPull,
    [switch]$NoExtension
)

$ErrorActionPreference = "Stop"

# --- Resolve paths dynamically ---
$ScriptDir = $PSScriptRoot
$QaAgentsDir = (Resolve-Path "$ScriptDir\..").Path
$WorkspaceRoot = (Resolve-Path "$QaAgentsDir\..").Path
$ExtDir = Join-Path $QaAgentsDir ".vscode-extension"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Blue
Write-Host " HealthBridge QA Agents - Update" -ForegroundColor Blue
Write-Host "=============================================" -ForegroundColor Blue
Write-Host ""
Write-Host "Workspace root: " -NoNewline; Write-Host $WorkspaceRoot -ForegroundColor White
Write-Host "QA Agents repo: " -NoNewline; Write-Host $QaAgentsDir -ForegroundColor White
Write-Host ""

# --- Helper functions ---
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

function Files-Are-Identical($Path1, $Path2) {
    if (-not (Test-Path $Path1) -or -not (Test-Path $Path2)) { return $false }
    $hash1 = (Get-FileHash -Path $Path1 -Algorithm MD5).Hash
    $hash2 = (Get-FileHash -Path $Path2 -Algorithm MD5).Hash
    return $hash1 -eq $hash2
}

$TotalSteps = 4
$Updated = 0
$Skipped = 0

# =============================================================================
# Step 1: Pull latest changes
# =============================================================================
Write-Host "[1/$TotalSteps] " -ForegroundColor Blue -NoNewline
Write-Host "Pulling latest changes" -ForegroundColor White

if ($NoPull) {
    Print-Skip "git pull (-NoPull flag)"
} else {
    Push-Location $QaAgentsDir
    try {
        $ErrorActionPreference = "Continue"
        $CurrentBranch = git rev-parse --abbrev-ref HEAD 2>$null
        $Before = git rev-parse HEAD 2>$null

        git pull --ff-only 2>$null
        $ErrorActionPreference = "Stop"
        if ($LASTEXITCODE -ne 0) { throw "git pull failed" }

        $ErrorActionPreference = "Continue"
        $After = git rev-parse HEAD 2>$null
        $ErrorActionPreference = "Stop"
        if ($Before -eq $After) {
            Print-Ok "Already up to date (branch: $CurrentBranch)"
        } else {
            $ErrorActionPreference = "Continue"
            $CommitCount = git rev-list --count "$Before..$After" 2>$null
            $ErrorActionPreference = "Stop"
            Print-Ok "Pulled $CommitCount new commit(s) (branch: $CurrentBranch)"
        }
    } catch {
        Print-Fail "git pull failed - you may have local changes. Try: git stash; .\setup\update.ps1"
        Pop-Location
        exit 1
    }
    Pop-Location
}
Write-Host ""

# =============================================================================
# Step 2: Copy AI configuration files
# =============================================================================
Write-Host "[2/$TotalSteps] " -ForegroundColor Blue -NoNewline
Write-Host "Syncing AI configuration files" -ForegroundColor White

# --- .claude\CLAUDE.md ---
$ClaudeSrc = Join-Path $QaAgentsDir ".claude\CLAUDE.md"
$ClaudeDst = Join-Path $WorkspaceRoot ".claude\CLAUDE.md"

if (Test-Path $ClaudeSrc) {
    if (Files-Are-Identical $ClaudeSrc $ClaudeDst) {
        Print-Skip ".claude\CLAUDE.md (no changes)"
        $Skipped++
    } else {
        New-Item -ItemType Directory -Path (Join-Path $WorkspaceRoot ".claude") -Force | Out-Null
        Copy-Item -Path $ClaudeSrc -Destination $ClaudeDst -Force
        Print-Ok ".claude\CLAUDE.md"
        $Updated++
    }
} else {
    Print-Fail ".claude\CLAUDE.md (source not found)"
}

# --- .cursorrules ---
$CursorSrc = Join-Path $QaAgentsDir ".cursorrules"
$CursorDst = Join-Path $WorkspaceRoot ".cursorrules"

if (Test-Path $CursorSrc) {
    if (Files-Are-Identical $CursorSrc $CursorDst) {
        Print-Skip ".cursorrules (no changes)"
        $Skipped++
    } else {
        Copy-Item -Path $CursorSrc -Destination $CursorDst -Force
        Print-Ok ".cursorrules"
        $Updated++
    }
} else {
    Print-Fail ".cursorrules (source not found)"
}

# --- .github\copilot-instructions.md ---
$CopilotSrc = Join-Path $QaAgentsDir ".github\copilot-instructions.md"
$CopilotDst = Join-Path $WorkspaceRoot ".github\copilot-instructions.md"

if (Test-Path $CopilotSrc) {
    if (Files-Are-Identical $CopilotSrc $CopilotDst) {
        Print-Skip ".github\copilot-instructions.md (no changes)"
        $Skipped++
    } else {
        New-Item -ItemType Directory -Path (Join-Path $WorkspaceRoot ".github") -Force | Out-Null
        Copy-Item -Path $CopilotSrc -Destination $CopilotDst -Force
        Print-Ok ".github\copilot-instructions.md"
        $Updated++
    }
} else {
    Print-Fail ".github\copilot-instructions.md (source not found)"
}

# --- HealthBridge.code-workspace ---
$WorkspaceSrc = Join-Path $QaAgentsDir "HealthBridge.code-workspace"
$WorkspaceDst = Join-Path $WorkspaceRoot "HealthBridge.code-workspace"

if (Test-Path $WorkspaceSrc) {
    if (Files-Are-Identical $WorkspaceSrc $WorkspaceDst) {
        Print-Skip "HealthBridge.code-workspace (no changes)"
        $Skipped++
    } else {
        Copy-Item -Path $WorkspaceSrc -Destination $WorkspaceDst -Force
        Print-Ok "HealthBridge.code-workspace"
        $Updated++
    }
} else {
    Print-Skip "HealthBridge.code-workspace (source not found)"
}

# --- update.bat ---
$UpdateBatSrc = Join-Path $QaAgentsDir "setup\update.bat"
$UpdateBatDst = Join-Path $WorkspaceRoot "update.bat"

if (Test-Path $UpdateBatSrc) {
    if (Files-Are-Identical $UpdateBatSrc $UpdateBatDst) {
        Print-Skip "update.bat (no changes)"
        $Skipped++
    } else {
        Copy-Item -Path $UpdateBatSrc -Destination $UpdateBatDst -Force
        Print-Ok "update.bat"
        $Updated++
    }
} else {
    Print-Skip "update.bat (source not found)"
}
Write-Host ""

# =============================================================================
# Step 3: Rebuild VS Code extension
# =============================================================================
Write-Host "[3/$TotalSteps] " -ForegroundColor Blue -NoNewline
Write-Host "Rebuilding VS Code extension" -ForegroundColor White

if ($NoExtension) {
    Print-Skip "Extension rebuild (-NoExtension flag)"
} elseif (-not (Test-Path $ExtDir)) {
    Print-Skip ".vscode-extension directory not found"
} else {
    $NodeExists = Get-Command node -ErrorAction SilentlyContinue
    if (-not $NodeExists) {
        Print-Fail "Node.js not installed - skipping extension rebuild"
        Write-Host "  Install from: https://nodejs.org/" -ForegroundColor Yellow
    } else {
        Push-Location $ExtDir

        $ErrorActionPreference = "Continue"

        Write-Host "  Installing dependencies..."
        npm install --silent 2>$null
        $ErrorActionPreference = "Stop"
        Print-Ok "npm install"

        Write-Host "  Compiling..."
        $ErrorActionPreference = "Continue"
        npm run compile --silent 2>$null
        $ErrorActionPreference = "Stop"
        Print-Ok "npm run compile"

        Write-Host "  Packaging..."
        cmd /c "npx vsce package --allow-missing-repository 2>nul"
        Print-Ok "vsce package"

        $ErrorActionPreference = "Stop"

        $VsixFile = Get-ChildItem -Path $ExtDir -Filter "*.vsix" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

        if (-not $VsixFile) {
            Print-Fail "No .vsix file found after packaging"
        } else {
            $CodeExists = Get-Command code -ErrorAction SilentlyContinue
            if ($CodeExists) {
                $ErrorActionPreference = "Continue"
                code --install-extension $VsixFile.FullName --force 2>$null
                $ErrorActionPreference = "Stop"
                Print-Ok "Extension installed via 'code' CLI"
            } else {
                Print-Fail "VS Code CLI not found"
                Write-Host "  Install manually: code --install-extension $($VsixFile.FullName) --force" -ForegroundColor Yellow
            }
        }

        Pop-Location
    }
}
Write-Host ""

# =============================================================================
# Step 4: Summary
# =============================================================================
Write-Host "[4/$TotalSteps] " -ForegroundColor Blue -NoNewline
Write-Host "Summary" -ForegroundColor White
Write-Host ""

if ($Updated -gt 0) {
    Write-Host "  Config files updated: $Updated | Unchanged: $Skipped" -ForegroundColor Green
} else {
    Write-Host "  Config files: all up to date" -ForegroundColor Green
}
Write-Host ""
Write-Host "  To apply changes:" -ForegroundColor White
Write-Host "  - VS Code extension: " -NoNewline; Write-Host "Reload window (F1 > 'Developer: Reload Window')" -ForegroundColor Cyan
Write-Host "  - Claude Code: " -NoNewline; Write-Host "Start a new conversation or use /refresh" -ForegroundColor Cyan
Write-Host "  - Cursor: " -NoNewline; Write-Host "Open a new chat (close existing chat tab)" -ForegroundColor Cyan
Write-Host "  - GitHub Copilot: " -NoNewline; Write-Host "Open a new Copilot Chat session" -ForegroundColor Cyan
Write-Host ""
