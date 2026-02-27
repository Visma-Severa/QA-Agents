#!/bin/bash

# =============================================================================
# HealthBridge QA Agents - Update VS Code Extension (macOS/Linux)
# =============================================================================
# Rebuilds and reinstalls the VS Code chat extension after pulling changes.
#
# Usage:
#   ./setup/update-extension.sh
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
EXT_DIR="$QA_AGENTS_DIR/.vscode-extension"

echo -e "${BOLD}${BLUE}=============================================${NC}"
echo -e "${BOLD}${BLUE} HealthBridge QA Agents - Extension Update${NC}"
echo -e "${BOLD}${BLUE}=============================================${NC}"
echo ""

# --- Validate ---
if [ ! -d "$EXT_DIR" ]; then
    echo -e "${RED}Error: .vscode-extension directory not found at:${NC}"
    echo -e "  $EXT_DIR"
    exit 1
fi

if ! command -v node &>/dev/null; then
    echo -e "${RED}Error: Node.js is not installed. Install it from https://nodejs.org/${NC}"
    exit 1
fi

cd "$EXT_DIR"

# --- Step 1: Install dependencies ---
echo -e "${BLUE}[1/4]${NC} Installing dependencies..."
npm install --silent 2>/dev/null
echo -e "  ${GREEN}OK${NC} npm install"

# --- Step 2: Compile ---
echo -e "${BLUE}[2/4]${NC} Compiling extension..."
npm run compile --silent 2>/dev/null
echo -e "  ${GREEN}OK${NC} npm run compile"

# --- Step 3: Package ---
echo -e "${BLUE}[3/4]${NC} Packaging extension..."
echo -e "y\ny" | npx vsce package --allow-missing-repository 2>/dev/null
echo -e "  ${GREEN}OK${NC} vsce package"

# --- Step 4: Install ---
echo -e "${BLUE}[4/4]${NC} Installing extension..."

VSIX_FILE=$(ls -t "$EXT_DIR"/*.vsix 2>/dev/null | head -1)

if [ -z "$VSIX_FILE" ]; then
    echo -e "  ${RED}FAIL${NC} No .vsix file found after packaging"
    exit 1
fi

if command -v code &>/dev/null; then
    code --install-extension "$VSIX_FILE" --force 2>/dev/null
    echo -e "  ${GREEN}OK${NC} Extension installed via 'code' CLI"
elif [ -f "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" --install-extension "$VSIX_FILE" --force 2>/dev/null
    echo -e "  ${GREEN}OK${NC} Extension installed via VS Code.app"
else
    echo -e "  ${RED}FAIL${NC} VS Code CLI not found"
    echo -e "  ${YELLOW}Install manually:${NC} code --install-extension $VSIX_FILE --force"
    echo -e "  ${YELLOW}macOS tip:${NC} Open VS Code > Command Palette > 'Shell Command: Install code command in PATH'"
    exit 1
fi

echo ""
echo -e "${GREEN}${BOLD}Extension updated successfully!${NC}"
echo ""
echo -e "Reload VS Code to activate: ${BLUE}F1 > 'Developer: Reload Window'${NC}"
echo ""
