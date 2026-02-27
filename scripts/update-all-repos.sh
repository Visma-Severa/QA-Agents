#!/bin/bash

# Update All Repositories Script
# This script pulls the latest changes from all critical repositories
# Run this regularly to ensure E2E tests, Mobile app, and QA Agents are up-to-date

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Updating All Repositories${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to update a repository
update_repo() {
    local repo_name=$1
    local repo_path=$2
    local branch=$3

    echo -e "${BLUE}Updating: ${repo_name}${NC}"

    if [ ! -d "$repo_path" ]; then
        echo -e "${RED}Repository not found: ${repo_path}${NC}"
        return 1
    fi

    cd "$repo_path"

    # Fetch latest changes
    git fetch origin

    # Get current branch
    current_branch=$(git branch --show-current)

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo -e "${RED}Warning: Uncommitted changes detected in ${repo_name}${NC}"
        echo -e "${RED}   Stashing changes...${NC}"
        git stash push -u -m "Auto-stash before update-all-repos.sh on $(date)"
    fi

    # Checkout target branch if different
    if [ "$current_branch" != "$branch" ]; then
        echo "   Switching from ${current_branch} to ${branch}"
        git checkout "$branch"
    fi

    # Pull latest changes
    git pull origin "$branch"

    echo -e "${GREEN}${repo_name} updated successfully${NC}"
    echo ""
}

# Update E2E Test Repositories
echo -e "${BLUE}E2E Test Repositories${NC}"
echo ""

update_repo "Selenium Tests" \
    "$WORKSPACE_ROOT/HealthBridge-Selenium-Tests" \
    "main"

update_repo "Playwright E2E Tests" \
    "$WORKSPACE_ROOT/HealthBridge-E2E-Tests" \
    "main"

update_repo "Mobile Tests" \
    "$WORKSPACE_ROOT/HealthBridge-Mobile-Tests" \
    "main"

# Update Mobile Repository
echo -e "${BLUE}Mobile Application${NC}"
echo ""

update_repo "HealthBridge Mobile" \
    "$WORKSPACE_ROOT/HealthBridge-Mobile" \
    "main"

# Update QA Agents Repository
echo -e "${BLUE}QA Agents${NC}"
echo ""

update_repo "DEMO QA Agents" \
    "$WORKSPACE_ROOT/DEMO-QA-Agents" \
    "main"

# Summary
echo -e "${GREEN}All repositories updated successfully!${NC}"
echo ""
echo "Updated repositories:"
echo "  - HealthBridge-Selenium-Tests"
echo "  - HealthBridge-E2E-Tests"
echo "  - HealthBridge-Mobile-Tests"
echo "  - HealthBridge-Mobile"
echo "  - DEMO-QA-Agents"
echo ""
echo "Note: If any uncommitted changes were found, they were stashed."
echo "To restore: cd <repo> && git stash pop"
