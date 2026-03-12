#!/bin/bash

# =============================================================================
# HealthBridge QA Agents - Full Environment Setup (macOS/Linux)
# =============================================================================
# This script sets up the complete multi-repository workspace:
#   1. Clones all repositories (skips existing ones)
#   2. Copies workspace file and AI configuration files
#   3. Sets up .claude/ directory with CLAUDE.md
#   4. Builds and installs the VS Code chat extension
#
# Usage:
#   ./setup/setup.sh                    # Run from QA Agents repo
#   ./setup/setup.sh /path/to/target    # Specify workspace parent directory
# =============================================================================

set -e

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# --- Resolve paths dynamically ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QA_AGENTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
QA_AGENTS_REPO_NAME="$(basename "$QA_AGENTS_DIR")"

# Determine workspace root (parent of QA Agents repo)
if [ -n "$1" ]; then
    WORKSPACE_ROOT="$(cd "$1" 2>/dev/null && pwd || mkdir -p "$1" && cd "$1" && pwd)"
else
    WORKSPACE_ROOT="$(cd "$QA_AGENTS_DIR/.." && pwd)"
fi

echo -e "${BOLD}${BLUE}=============================================${NC}"
echo -e "${BOLD}${BLUE} HealthBridge QA Agents - Environment Setup${NC}"
echo -e "${BOLD}${BLUE}=============================================${NC}"
echo ""
echo -e "Workspace root: ${BOLD}$WORKSPACE_ROOT${NC}"
echo -e "QA Agents repo: ${BOLD}$QA_AGENTS_DIR${NC}"
echo ""

# --- Helper functions ---
print_step() {
    echo -e "${BLUE}[Step $1/$TOTAL_STEPS]${NC} ${BOLD}$2${NC}"
}

print_ok() {
    echo -e "  ${GREEN}OK${NC} $1"
}

print_skip() {
    echo -e "  ${YELLOW}SKIP${NC} $1"
}

print_fail() {
    echo -e "  ${RED}FAIL${NC} $1"
}

TOTAL_STEPS=6

# =============================================================================
# Step 1: Clone all repositories
# =============================================================================
print_step 1 "Cloning repositories"
echo ""

# Each entry: "repo-name=clone-url"
REPOS=(
    # Core application repositories
    "HealthBridge-Web=https://github.com/healthbridge-org/HealthBridge-Web.git"
    "HealthBridge-Portal=https://github.com/healthbridge-org/HealthBridge-Portal.git"
    "HealthBridge-Api=https://github.com/healthbridge-org/HealthBridge-Api.git"
    "HealthBridge-Mobile=https://github.com/healthbridge-org/HealthBridge-Mobile.git"
    # Microservice API repositories
    "HealthBridge-Claims-Processing=https://github.com/healthbridge-org/HealthBridge-Claims-Processing.git"
    "HealthBridge-Prescriptions-Api=https://github.com/healthbridge-org/HealthBridge-Prescriptions-Api.git"
    # Test automation repositories
    "HealthBridge-Selenium-Tests=https://github.com/healthbridge-org/HealthBridge-Selenium-Tests.git"
    "HealthBridge-E2E-Tests=https://github.com/healthbridge-org/HealthBridge-E2E-Tests.git"
    "HealthBridge-Mobile-Tests=https://github.com/healthbridge-org/HealthBridge-Mobile-Tests.git"
)

cloned=0
skipped=0

for entry in "${REPOS[@]}"; do
    repo="${entry%%=*}"
    url="${entry#*=}"
    target="$WORKSPACE_ROOT/$repo"
    if [ -d "$target" ]; then
        print_skip "$repo (already exists)"
        skipped=$((skipped + 1))
    else
        echo -e "  Cloning ${BOLD}$repo${NC}..."
        if git clone "$url" "$target" 2>/dev/null; then
            print_ok "$repo"
            cloned=$((cloned + 1))
        else
            print_fail "$repo (clone failed — check access)"
        fi
    fi
done

echo ""
echo -e "  Cloned: ${GREEN}$cloned${NC} | Skipped: ${YELLOW}$skipped${NC}"
echo ""

# =============================================================================
# Step 2: Copy workspace file
# =============================================================================
print_step 2 "Copying workspace file"

WORKSPACE_FILE="$QA_AGENTS_DIR/HealthBridge.code-workspace"
TARGET_WORKSPACE="$WORKSPACE_ROOT/HealthBridge.code-workspace"

if [ -f "$WORKSPACE_FILE" ]; then
    cp "$WORKSPACE_FILE" "$TARGET_WORKSPACE"
    print_ok "HealthBridge.code-workspace copied to workspace root"
else
    print_fail "HealthBridge.code-workspace not found in QA Agents repo"
fi
echo ""

# =============================================================================
# Step 3: Copy AI configuration files
# =============================================================================
print_step 3 "Copying AI configuration files"

# Copilot instructions
COPILOT_SRC="$QA_AGENTS_DIR/.github/copilot-instructions.md"
COPILOT_DST="$WORKSPACE_ROOT/.github/copilot-instructions.md"

if [ -f "$COPILOT_SRC" ]; then
    mkdir -p "$WORKSPACE_ROOT/.github"
    cp "$COPILOT_SRC" "$COPILOT_DST"
    print_ok ".github/copilot-instructions.md"
else
    print_skip ".github/copilot-instructions.md (source not found)"
fi

# Cursor rules
CURSOR_SRC="$QA_AGENTS_DIR/.cursorrules"
CURSOR_DST="$WORKSPACE_ROOT/.cursorrules"

if [ -f "$CURSOR_SRC" ]; then
    cp "$CURSOR_SRC" "$CURSOR_DST"
    print_ok ".cursorrules"
else
    print_skip ".cursorrules (source not found)"
fi

# Claude Code instructions
CLAUDE_SRC="$QA_AGENTS_DIR/.claude"
CLAUDE_DST="$WORKSPACE_ROOT/.claude"

if [ -d "$CLAUDE_SRC" ] && [ -f "$CLAUDE_SRC/CLAUDE.md" ]; then
    mkdir -p "$CLAUDE_DST"
    cp "$CLAUDE_SRC/CLAUDE.md" "$CLAUDE_DST/CLAUDE.md"
    print_ok ".claude/CLAUDE.md"
elif [ -f "$CLAUDE_DST/CLAUDE.md" ]; then
    print_skip ".claude/CLAUDE.md (already exists)"
else
    print_skip ".claude/CLAUDE.md (source not found in QA Agents repo)"
fi
echo ""

# =============================================================================
# Step 4: Create reports directories
# =============================================================================
print_step 4 "Creating reports directories"

REPORTS_DIR="$QA_AGENTS_DIR/reports"
REPORT_SUBDIRS=(
    "code-review"
    "acceptance-tests"
    "bug-reports"
    "bugfix-rca"
    "requirements-analysis"
    "week-release"
    "feedback"
    "dev-estimation"
    "qa-test-plan"
)

for subdir in "${REPORT_SUBDIRS[@]}"; do
    mkdir -p "$REPORTS_DIR/$subdir"
done
print_ok "reports/ with ${#REPORT_SUBDIRS[@]} subdirectories"
echo ""

# =============================================================================
# Step 5: Build and install VS Code extension
# =============================================================================
print_step 5 "Building and installing VS Code extension"

EXT_DIR="$QA_AGENTS_DIR/.vscode-extension"

if [ ! -d "$EXT_DIR" ]; then
    print_fail ".vscode-extension directory not found"
    echo ""
else
    # Check for Node.js
    if ! command -v node &>/dev/null; then
        print_fail "Node.js is not installed. Install it from https://nodejs.org/"
        echo ""
    elif ! command -v npm &>/dev/null; then
        print_fail "npm is not installed. Install Node.js from https://nodejs.org/"
        echo ""
    else
        cd "$EXT_DIR"

        echo -e "  Installing dependencies..."
        npm install --silent 2>/dev/null
        print_ok "npm install"

        echo -e "  Compiling extension..."
        npm run compile --silent 2>/dev/null
        print_ok "npm run compile"

        echo -e "  Packaging extension..."
        echo -e "y\ny" | npx vsce package --allow-missing-repository 2>/dev/null
        print_ok "vsce package"

        # Find the generated VSIX file
        VSIX_FILE=$(ls -t "$EXT_DIR"/*.vsix 2>/dev/null | head -1)

        if [ -z "$VSIX_FILE" ]; then
            print_fail "No .vsix file found after packaging"
        else
            echo -e "  Installing extension..."
            # Try 'code' CLI first, fall back to macOS full path
            if command -v code &>/dev/null; then
                code --install-extension "$VSIX_FILE" --force 2>/dev/null
                print_ok "Extension installed via 'code' CLI"
            elif [ -f "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
                "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" --install-extension "$VSIX_FILE" --force 2>/dev/null
                print_ok "Extension installed via VS Code.app"
            else
                print_fail "VS Code CLI not found"
                echo -e "  ${YELLOW}Install manually:${NC} code --install-extension $VSIX_FILE --force"
                echo -e "  ${YELLOW}macOS tip:${NC} Open VS Code > Command Palette > 'Shell Command: Install code command in PATH'"
            fi
        fi

        cd "$WORKSPACE_ROOT"
        echo ""
    fi
fi

# =============================================================================
# Step 6: Summary and next steps
# =============================================================================
print_step 6 "Setup complete"
echo ""

echo -e "${GREEN}${BOLD}=============================================${NC}"
echo -e "${GREEN}${BOLD} Setup Complete!${NC}"
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo ""
echo -e "${BOLD}Workspace:${NC} $WORKSPACE_ROOT"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo "  1. Open the workspace in VS Code:"
echo -e "     ${BLUE}code $TARGET_WORKSPACE${NC}"
echo ""
echo "  2. Reload VS Code (F1 > 'Developer: Reload Window')"
echo ""
echo "  3. Verify agents: type @hb in GitHub Copilot Chat"
echo ""
echo -e "${BOLD}To update the extension later:${NC}"
echo -e "     ${BLUE}$SCRIPT_DIR/update-extension.sh${NC}"
echo ""
