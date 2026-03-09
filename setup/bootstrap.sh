#!/bin/bash

# =============================================================================
# QA Agents Framework — Bootstrap (macOS/Linux)
# =============================================================================
# Creates a new QA Agents project from the DEMO template.
# Copies all framework files into a new folder WITHOUT modifying the DEMO.
#
# Usage:
#   ./setup/bootstrap.sh MyProject                     # Creates ../MyProject-QA-Agents/
#   ./setup/bootstrap.sh MyProject /path/to/target     # Creates /path/to/target/MyProject-QA-Agents/
#
# After bootstrap:
#   1. cd into the new folder
#   2. Build & install the VS Code extension
#   3. Run @setup agent to customize for your project
# =============================================================================

set -e

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# --- Resolve paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Validate arguments ---
if [ -z "$1" ]; then
    echo -e "${RED}Error: Project name is required.${NC}"
    echo ""
    echo "Usage:"
    echo "  ./setup/bootstrap.sh <ProjectName>                  # Creates ../<ProjectName>-QA-Agents/"
    echo "  ./setup/bootstrap.sh <ProjectName> /path/to/target  # Creates at target location"
    echo ""
    echo "Example:"
    echo "  ./setup/bootstrap.sh Falcon"
    echo "  ./setup/bootstrap.sh \"Acme Platform\" ~/Projects"
    exit 1
fi

PROJECT_NAME="$1"
# Create a filesystem-safe name (lowercase, hyphens instead of spaces)
PROJECT_SLUG="$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')"
REPO_NAME="${PROJECT_SLUG}-qa-agents"

# Determine target parent directory
if [ -n "$2" ]; then
    TARGET_PARENT="$(mkdir -p "$2" && cd "$2" && pwd)"
else
    TARGET_PARENT="$(cd "$DEMO_DIR/.." && pwd)"
fi

TARGET_DIR="$TARGET_PARENT/$REPO_NAME"

echo -e "${BOLD}${BLUE}=============================================${NC}"
echo -e "${BOLD}${BLUE} QA Agents Framework — Bootstrap${NC}"
echo -e "${BOLD}${BLUE}=============================================${NC}"
echo ""
echo -e "Project name:  ${BOLD}$PROJECT_NAME${NC}"
echo -e "Folder name:   ${BOLD}$REPO_NAME${NC}"
echo -e "Target:        ${BOLD}$TARGET_DIR${NC}"
echo -e "Source (DEMO): ${BOLD}$DEMO_DIR${NC}"
echo ""

# --- Check target doesn't already exist ---
if [ -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target directory already exists:${NC}"
    echo "  $TARGET_DIR"
    echo ""
    echo "Remove it first or choose a different name."
    exit 1
fi

# =============================================================================
# Step 1: Copy DEMO files to new directory
# =============================================================================
echo -e "${BLUE}[1/4]${NC} ${BOLD}Copying framework files${NC}"

# Use rsync if available (preserves permissions, cleaner exclude), fall back to cp
if command -v rsync &>/dev/null; then
    rsync -a \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='dist' \
        --exclude='*.vsix' \
        --exclude='package-lock.json' \
        --exclude='reports/*/*.md' \
        "$DEMO_DIR/" "$TARGET_DIR/"
    echo -e "  ${GREEN}OK${NC} Copied via rsync (excluding .git, node_modules, dist, *.vsix, reports)"
else
    mkdir -p "$TARGET_DIR"
    # Copy everything except .git and build artifacts
    cd "$DEMO_DIR"
    find . -mindepth 1 \
        -not -path './.git' -not -path './.git/*' \
        -not -path './node_modules' -not -path './node_modules/*' \
        -not -path './.vscode-extension/node_modules' -not -path './.vscode-extension/node_modules/*' \
        -not -path './.vscode-extension/dist' -not -path './.vscode-extension/dist/*' \
        -not -name '*.vsix' \
        -not -name 'package-lock.json' \
        | while IFS= read -r item; do
            if [ -d "$item" ]; then
                mkdir -p "$TARGET_DIR/$item"
            else
                cp "$item" "$TARGET_DIR/$item"
            fi
        done
    echo -e "  ${GREEN}OK${NC} Copied via cp (excluding .git, node_modules, dist, *.vsix)"
fi

# =============================================================================
# Step 2: Initialize fresh git repository
# =============================================================================
echo -e "${BLUE}[2/4]${NC} ${BOLD}Initializing git repository${NC}"

cd "$TARGET_DIR"
git init -q
git add -A
git commit -q -m "Initial commit: QA Agents framework from DEMO template"
echo -e "  ${GREEN}OK${NC} Git initialized with initial commit"

# =============================================================================
# Step 3: Create report directories with .gitkeep
# =============================================================================
echo -e "${BLUE}[3/4]${NC} ${BOLD}Creating report directories${NC}"

REPORT_DIRS=(
    "reports/acceptance-tests"
    "reports/bug-report"
    "reports/bugfix-rca"
    "reports/code-review"
    "reports/feedback"
    "reports/release-analysis"
    "reports/requirements-analysis"
)

for dir in "${REPORT_DIRS[@]}"; do
    mkdir -p "$TARGET_DIR/$dir"
    touch "$TARGET_DIR/$dir/.gitkeep"
done
echo -e "  ${GREEN}OK${NC} ${#REPORT_DIRS[@]} report directories created"

# =============================================================================
# Step 4: Summary and next steps
# =============================================================================
echo ""
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo -e "${GREEN}${BOLD} Bootstrap Complete!${NC}"
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo ""
echo -e "${BOLD}Your new project:${NC} $TARGET_DIR"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo "  1. Navigate to your project:"
echo -e "     ${BLUE}cd $TARGET_DIR${NC}"
echo ""
echo "  2. Build & install the VS Code extension:"
echo -e "     ${BLUE}cd .vscode-extension && npm install && npm run compile${NC}"
echo -e "     ${BLUE}npx vsce package --allow-missing-repository${NC}"
echo -e "     ${BLUE}code --install-extension *.vsix --force${NC}"
echo -e "     ${BLUE}cd ..${NC}"
echo ""
echo "  3. Open in your IDE and run the Setup Agent:"
echo -e "     ${BLUE}@hb-setup${NC}"
echo ""
echo "  The Setup Agent will ask about your project (name, repos, ticket"
echo "  prefixes, domains) and update all files automatically."
echo ""
echo "  4. After setup, run the environment setup script to clone your repos:"
echo -e "     ${BLUE}./setup/setup.sh${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} The DEMO template is unchanged — you can bootstrap again for another project."
echo ""
