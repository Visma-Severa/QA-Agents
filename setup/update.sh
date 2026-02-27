#!/bin/bash

# =============================================================================
# HealthBridge QA Agents - Update (macOS/Linux)
# =============================================================================
# Single command to update everything after the QA Agents repo has new changes:
#   1. Pulls latest changes (git pull)
#   2. Syncs AI config files to workspace root
#   3. Rebuilds and reinstalls VS Code chat extension
#
# Usage:
#   ./setup/update.sh                # Full update (pull + config + extension)
#   ./setup/update.sh --no-pull      # Skip git pull
#   ./setup/update.sh --no-extension # Skip VS Code extension rebuild
# =============================================================================

set -e

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# --- Parse arguments ---
NO_PULL=false
NO_EXTENSION=false
for arg in "$@"; do
    case $arg in
        --no-pull) NO_PULL=true ;;
        --no-extension) NO_EXTENSION=true ;;
    esac
done

# --- Resolve paths dynamically ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QA_AGENTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_ROOT="$(cd "$QA_AGENTS_DIR/.." && pwd)"
EXT_DIR="$QA_AGENTS_DIR/.vscode-extension"

echo -e "${BOLD}${BLUE}=============================================${NC}"
echo -e "${BOLD}${BLUE} HealthBridge QA Agents - Update${NC}"
echo -e "${BOLD}${BLUE}=============================================${NC}"
echo ""
echo -e "Workspace root: ${BOLD}$WORKSPACE_ROOT${NC}"
echo -e "QA Agents repo: ${BOLD}$QA_AGENTS_DIR${NC}"
echo ""

# --- Helper functions ---
print_ok() {
    echo -e "  ${GREEN}OK${NC} $1"
}

print_skip() {
    echo -e "  ${YELLOW}SKIP${NC} $1"
}

print_fail() {
    echo -e "  ${RED}FAIL${NC} $1"
}

TOTAL_STEPS=4
updated=0
skipped=0

# =============================================================================
# Step 1: Pull latest changes
# =============================================================================
echo -e "${BLUE}[1/$TOTAL_STEPS]${NC} ${BOLD}Pulling latest changes${NC}"

if [ "$NO_PULL" = true ]; then
    print_skip "git pull (--no-pull flag)"
else
    cd "$QA_AGENTS_DIR"
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    BEFORE=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

    if git pull --ff-only 2>/dev/null; then
        AFTER=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
        if [ "$BEFORE" = "$AFTER" ]; then
            print_ok "Already up to date (branch: $CURRENT_BRANCH)"
        else
            COMMIT_COUNT=$(git rev-list --count "$BEFORE..$AFTER" 2>/dev/null || echo "?")
            print_ok "Pulled $COMMIT_COUNT new commit(s) (branch: $CURRENT_BRANCH)"
        fi
    else
        print_fail "git pull failed — you may have local changes. Try: git stash && ./setup/update.sh"
        echo ""
        exit 1
    fi
fi
echo ""

# =============================================================================
# Step 2: Copy AI configuration files
# =============================================================================
echo -e "${BLUE}[2/$TOTAL_STEPS]${NC} ${BOLD}Syncing AI configuration files${NC}"

# --- .claude/CLAUDE.md ---
CLAUDE_SRC="$QA_AGENTS_DIR/.claude/CLAUDE.md"
CLAUDE_DST="$WORKSPACE_ROOT/.claude/CLAUDE.md"

if [ -f "$CLAUDE_SRC" ]; then
    mkdir -p "$WORKSPACE_ROOT/.claude"
    if [ -f "$CLAUDE_DST" ] && diff -q "$CLAUDE_SRC" "$CLAUDE_DST" > /dev/null 2>&1; then
        print_skip ".claude/CLAUDE.md (no changes)"
        skipped=$((skipped + 1))
    else
        cp "$CLAUDE_SRC" "$CLAUDE_DST"
        print_ok ".claude/CLAUDE.md"
        updated=$((updated + 1))
    fi
else
    print_fail ".claude/CLAUDE.md (source not found)"
fi

# --- .cursorrules ---
CURSOR_SRC="$QA_AGENTS_DIR/.cursorrules"
CURSOR_DST="$WORKSPACE_ROOT/.cursorrules"

if [ -f "$CURSOR_SRC" ]; then
    if [ -f "$CURSOR_DST" ] && diff -q "$CURSOR_SRC" "$CURSOR_DST" > /dev/null 2>&1; then
        print_skip ".cursorrules (no changes)"
        skipped=$((skipped + 1))
    else
        cp "$CURSOR_SRC" "$CURSOR_DST"
        print_ok ".cursorrules"
        updated=$((updated + 1))
    fi
else
    print_fail ".cursorrules (source not found)"
fi

# --- .github/copilot-instructions.md ---
COPILOT_SRC="$QA_AGENTS_DIR/.github/copilot-instructions.md"
COPILOT_DST="$WORKSPACE_ROOT/.github/copilot-instructions.md"

if [ -f "$COPILOT_SRC" ]; then
    mkdir -p "$WORKSPACE_ROOT/.github"
    if [ -f "$COPILOT_DST" ] && diff -q "$COPILOT_SRC" "$COPILOT_DST" > /dev/null 2>&1; then
        print_skip ".github/copilot-instructions.md (no changes)"
        skipped=$((skipped + 1))
    else
        cp "$COPILOT_SRC" "$COPILOT_DST"
        print_ok ".github/copilot-instructions.md"
        updated=$((updated + 1))
    fi
else
    print_fail ".github/copilot-instructions.md (source not found)"
fi

# --- HealthBridge.code-workspace ---
WORKSPACE_SRC="$QA_AGENTS_DIR/HealthBridge.code-workspace"
WORKSPACE_DST="$WORKSPACE_ROOT/HealthBridge.code-workspace"

if [ -f "$WORKSPACE_SRC" ]; then
    if [ -f "$WORKSPACE_DST" ] && diff -q "$WORKSPACE_SRC" "$WORKSPACE_DST" > /dev/null 2>&1; then
        print_skip "HealthBridge.code-workspace (no changes)"
        skipped=$((skipped + 1))
    else
        cp "$WORKSPACE_SRC" "$WORKSPACE_DST"
        print_ok "HealthBridge.code-workspace"
        updated=$((updated + 1))
    fi
else
    print_skip "HealthBridge.code-workspace (source not found)"
fi
echo ""

# =============================================================================
# Step 3: Rebuild VS Code extension
# =============================================================================
echo -e "${BLUE}[3/$TOTAL_STEPS]${NC} ${BOLD}Rebuilding VS Code extension${NC}"

if [ "$NO_EXTENSION" = true ]; then
    print_skip "Extension rebuild (--no-extension flag)"
elif [ ! -d "$EXT_DIR" ]; then
    print_skip ".vscode-extension directory not found"
elif ! command -v node &>/dev/null; then
    print_fail "Node.js not installed — skipping extension rebuild"
    echo -e "  ${YELLOW}Install from:${NC} https://nodejs.org/"
else
    cd "$EXT_DIR"

    echo -e "  Installing dependencies..."
    npm install --silent 2>/dev/null
    print_ok "npm install"

    echo -e "  Compiling..."
    npm run compile --silent 2>/dev/null
    print_ok "npm run compile"

    echo -e "  Packaging..."
    echo -e "y\ny" | npx vsce package --allow-missing-repository 2>/dev/null
    print_ok "vsce package"

    VSIX_FILE=$(ls -t "$EXT_DIR"/*.vsix 2>/dev/null | head -1)

    if [ -z "$VSIX_FILE" ]; then
        print_fail "No .vsix file found after packaging"
    elif command -v code &>/dev/null; then
        code --install-extension "$VSIX_FILE" --force 2>/dev/null
        print_ok "Extension installed via 'code' CLI"
    elif [ -f "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
        "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" --install-extension "$VSIX_FILE" --force 2>/dev/null
        print_ok "Extension installed via VS Code.app"
    else
        print_fail "VS Code CLI not found"
        echo -e "  ${YELLOW}Install manually:${NC} code --install-extension $VSIX_FILE --force"
    fi

    cd "$QA_AGENTS_DIR"
fi
echo ""

# =============================================================================
# Step 4: Summary
# =============================================================================
echo -e "${BLUE}[4/$TOTAL_STEPS]${NC} ${BOLD}Summary${NC}"
echo ""

if [ $updated -gt 0 ]; then
    echo -e "  ${GREEN}Config files updated: $updated${NC} | Unchanged: $skipped"
else
    echo -e "  ${GREEN}Config files: all up to date${NC}"
fi
echo ""
echo -e "  ${BOLD}To apply changes:${NC}"
echo -e "  - ${BOLD}VS Code extension:${NC} Reload window (F1 > 'Developer: Reload Window')"
echo -e "  - ${BOLD}Claude Code:${NC} Start a new conversation or use /refresh"
echo -e "  - ${BOLD}Cursor:${NC} Open a new chat (close existing chat tab)"
echo -e "  - ${BOLD}GitHub Copilot:${NC} Open a new Copilot Chat session"
echo ""
