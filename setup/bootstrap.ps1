# =============================================================================
# QA Agents Framework — Bootstrap (Windows PowerShell)
# =============================================================================
# Creates a new QA Agents project from the DEMO template.
# Copies all framework files into a new folder WITHOUT modifying the DEMO.
#
# Usage:
#   .\setup\bootstrap.ps1 -ProjectName "MyProject"
#   .\setup\bootstrap.ps1 -ProjectName "MyProject" -TargetDir "C:\Projects"
#
# After bootstrap:
#   1. cd into the new folder
#   2. Build & install the VS Code extension
#   3. Run @setup agent to customize for your project
# =============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    [string]$TargetDir
)

$ErrorActionPreference = "Stop"

# --- Resolve paths ---
$ScriptDir = $PSScriptRoot
$DemoDir = (Resolve-Path "$ScriptDir\..").Path

# Create filesystem-safe name
$ProjectSlug = $ProjectName.ToLower() -replace '\s+', '-' -replace '[^a-z0-9-]', ''
$RepoName = "$ProjectSlug-qa-agents"

# Determine target parent directory
if ($TargetDir) {
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }
    $TargetParent = (Resolve-Path $TargetDir).Path
} else {
    $TargetParent = (Resolve-Path "$DemoDir\..").Path
}

$TargetPath = Join-Path $TargetParent $RepoName

Write-Host ""
Write-Host "=============================================" -ForegroundColor Blue
Write-Host " QA Agents Framework - Bootstrap" -ForegroundColor Blue
Write-Host "=============================================" -ForegroundColor Blue
Write-Host ""
Write-Host "Project name:  " -NoNewline; Write-Host $ProjectName -ForegroundColor White
Write-Host "Folder name:   " -NoNewline; Write-Host $RepoName -ForegroundColor White
Write-Host "Target:        " -NoNewline; Write-Host $TargetPath -ForegroundColor White
Write-Host "Source (DEMO): " -NoNewline; Write-Host $DemoDir -ForegroundColor White
Write-Host ""

# --- Check target doesn't already exist ---
if (Test-Path $TargetPath) {
    Write-Host "Error: Target directory already exists:" -ForegroundColor Red
    Write-Host "  $TargetPath"
    Write-Host ""
    Write-Host "Remove it first or choose a different name."
    exit 1
}

# =============================================================================
# Step 1: Copy DEMO files to new directory
# =============================================================================
Write-Host "[1/4] " -ForegroundColor Blue -NoNewline
Write-Host "Copying framework files" -ForegroundColor White

# Copy everything except excluded directories/files
$ExcludeDirs = @('.git', 'node_modules', 'dist')
$ExcludeFiles = @('*.vsix', 'package-lock.json')

# Create target directory
New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null

# Get all items from source
$Items = Get-ChildItem -Path $DemoDir -Force | Where-Object {
    $_.Name -notin $ExcludeDirs
}

foreach ($Item in $Items) {
    if ($Item.PSIsContainer) {
        # Directory — use robocopy for selective copy (or xcopy fallback)
        $SrcPath = $Item.FullName
        $DstPath = Join-Path $TargetPath $Item.Name

        if ($Item.Name -eq '.vscode-extension') {
            # Special handling: exclude node_modules, dist, *.vsix
            robocopy $SrcPath $DstPath /E /XD node_modules dist /XF *.vsix package-lock.json /NFL /NDL /NJH /NJS /NC /NS /NP 2>$null | Out-Null
        } else {
            robocopy $SrcPath $DstPath /E /XD .git node_modules /XF *.vsix /NFL /NDL /NJH /NJS /NC /NS /NP 2>$null | Out-Null
        }
    } else {
        # File — copy unless excluded
        $Skip = $false
        foreach ($Pattern in $ExcludeFiles) {
            if ($Item.Name -like $Pattern) { $Skip = $true; break }
        }
        if (-not $Skip) {
            Copy-Item -Path $Item.FullName -Destination $TargetPath -Force
        }
    }
}

# Clean any report .md files (keep directories and .gitkeep)
$ReportMds = Get-ChildItem -Path (Join-Path $TargetPath "reports") -Recurse -Filter "*.md" -File -ErrorAction SilentlyContinue
foreach ($Md in $ReportMds) {
    Remove-Item $Md.FullName -Force
}

Write-Host "  OK " -ForegroundColor Green -NoNewline
Write-Host "Copied (excluding .git, node_modules, dist, *.vsix, reports)"

# =============================================================================
# Step 2: Initialize fresh git repository
# =============================================================================
Write-Host "[2/4] " -ForegroundColor Blue -NoNewline
Write-Host "Initializing git repository" -ForegroundColor White

Push-Location $TargetPath
git init -q 2>$null
git add -A 2>$null
git commit -q -m "Initial commit: QA Agents framework from DEMO template" 2>$null
Pop-Location

Write-Host "  OK " -ForegroundColor Green -NoNewline
Write-Host "Git initialized with initial commit"

# =============================================================================
# Step 3: Create report directories with .gitkeep
# =============================================================================
Write-Host "[3/4] " -ForegroundColor Blue -NoNewline
Write-Host "Creating report directories" -ForegroundColor White

$ReportDirs = @(
    "reports\acceptance-tests",
    "reports\bug-report",
    "reports\bugfix-rca",
    "reports\code-review",
    "reports\feedback",
    "reports\release-analysis",
    "reports\requirements-analysis"
)

foreach ($Dir in $ReportDirs) {
    $FullPath = Join-Path $TargetPath $Dir
    New-Item -ItemType Directory -Path $FullPath -Force | Out-Null
    $GitkeepPath = Join-Path $FullPath ".gitkeep"
    if (-not (Test-Path $GitkeepPath)) {
        New-Item -ItemType File -Path $GitkeepPath -Force | Out-Null
    }
}

Write-Host "  OK " -ForegroundColor Green -NoNewline
Write-Host "$($ReportDirs.Count) report directories created"

# =============================================================================
# Step 4: Summary and next steps
# =============================================================================
Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host " Bootstrap Complete!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your new project: " -NoNewline; Write-Host $TargetPath
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Navigate to your project:"
Write-Host "     cd $TargetPath" -ForegroundColor Blue
Write-Host ""
Write-Host "  2. Build & install the VS Code extension:"
Write-Host "     cd .vscode-extension; npm install; npm run compile" -ForegroundColor Blue
Write-Host "     npx vsce package --allow-missing-repository" -ForegroundColor Blue
Write-Host "     code --install-extension *.vsix --force" -ForegroundColor Blue
Write-Host "     cd .." -ForegroundColor Blue
Write-Host ""
Write-Host "  3. Open in your IDE and run the Setup Agent:"
Write-Host "     @hb-setup" -ForegroundColor Blue
Write-Host ""
Write-Host "  The Setup Agent will ask about your project (name, repos, ticket"
Write-Host "  prefixes, domains) and update all files automatically."
Write-Host ""
Write-Host "  4. After setup, run the environment setup script to clone your repos:"
Write-Host "     .\setup\setup.ps1" -ForegroundColor Blue
Write-Host ""
Write-Host "Note: " -ForegroundColor Yellow -NoNewline
Write-Host "The DEMO template is unchanged - you can bootstrap again for another project."
Write-Host ""
