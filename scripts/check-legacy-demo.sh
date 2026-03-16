#!/usr/bin/env bash
# =============================================================================
# check-legacy-demo.sh — Scan repo for legacy DEMO/HealthBridge references
# =============================================================================
# Searches all files for patterns from the original DEMO template that should
# have been replaced with ePayslip-specific content.
#
# Usage:
#   ./scripts/check-legacy-demo.sh              # default scan
#   ./scripts/check-legacy-demo.sh --fix-plan   # also emit a fix-plan summary
#
# Exit codes:  0 = clean,  1 = legacy references found
# Compatible with: macOS (bash 3.2+), Linux, Git Bash on Windows
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# ── Colours (disabled when piped) ──────────────────────────────────────────
if [ -t 1 ]; then
  RED='\033[0;31m'; YEL='\033[0;33m'; GRN='\033[0;32m'; CYN='\033[0;36m'
  BLD='\033[1m'; RST='\033[0m'
else
  RED=''; YEL=''; GRN=''; CYN=''; BLD=''; RST=''
fi

# ── Flags ──────────────────────────────────────────────────────────────────
FIX_PLAN=false
for arg in "$@"; do
  case "$arg" in
    --fix-plan) FIX_PLAN=true ;;
    --help|-h)
      echo "Usage: $0 [--fix-plan]"
      echo "  --fix-plan  Print a per-file fix plan at the end"
      exit 0
      ;;
  esac
done

# ── Exclude args for grep ─────────────────────────────────────────────────
EXCLUDE_ARGS=(
  --exclude="check-legacy-demo.sh"
  --exclude-dir=".git"
  --exclude-dir="node_modules"
  --exclude-dir="dist"
  --exclude="*.vsix"
  --exclude="*.png"
  --exclude="*.jpg"
  --exclude="*.ico"
  --exclude="package-lock.json"
)

# ── Temp files ─────────────────────────────────────────────────────────────
TMPFILE=$(mktemp)
FILECOUNTS=$(mktemp)
trap 'rm -f "$TMPFILE" "$FILECOUNTS"' EXIT

# ── Counters ───────────────────────────────────────────────────────────────
TOTAL_HITS=0
CAT_PROJECT_NAME=0
CAT_TICKET_PREFIX=0
CAT_REPO_NAME=0
CAT_DOMAIN_TERM=0
CAT_DEMO_REF=0
CAT_E2E_LEGACY=0

# ── Helper: scan one pattern ──────────────────────────────────────────────
scan_pattern() {
  local category="$1" pattern="$2" description="$3"

  grep -rnE "${EXCLUDE_ARGS[@]}" "$pattern" . > "$TMPFILE" 2>/dev/null || true
  if [ -s "$TMPFILE" ]; then
    local count
    count=$(wc -l < "$TMPFILE" | tr -d ' ')
    if [ "$count" -gt 0 ]; then
      TOTAL_HITS=$((TOTAL_HITS + count))

      # Increment category counter
      case "$category" in
        PROJECT_NAME)  CAT_PROJECT_NAME=$((CAT_PROJECT_NAME + count)) ;;
        TICKET_PREFIX) CAT_TICKET_PREFIX=$((CAT_TICKET_PREFIX + count)) ;;
        REPO_NAME)     CAT_REPO_NAME=$((CAT_REPO_NAME + count)) ;;
        DOMAIN_TERM)   CAT_DOMAIN_TERM=$((CAT_DOMAIN_TERM + count)) ;;
        DEMO_REF)      CAT_DEMO_REF=$((CAT_DEMO_REF + count)) ;;
        E2E_LEGACY)    CAT_E2E_LEGACY=$((CAT_E2E_LEGACY + count)) ;;
      esac

      echo -e "${RED}✗${RST} ${BLD}${description}${RST}  ${YEL}(${count} hit(s))${RST}  [${CYN}${category}${RST}]"

      # Show up to 5 matches
      local shown=0
      while IFS= read -r line && [ "$shown" -lt 5 ]; do
        local file lineno content
        file=$(echo "$line" | cut -d: -f1)
        lineno=$(echo "$line" | cut -d: -f2)
        content=$(echo "$line" | cut -d: -f3- | sed 's/^[[:space:]]*//' | cut -c1-120)
        echo -e "  ${CYN}${file}:${lineno}${RST}  ${content}"
        shown=$((shown + 1))
      done < "$TMPFILE"

      local remaining=$((count - 5))
      if [ "$remaining" -gt 0 ]; then
        echo -e "  ${YEL}... and ${remaining} more${RST}"
      fi

      # Collect per-file counts (append to FILECOUNTS for later aggregation)
      cut -d: -f1 "$TMPFILE" >> "$FILECOUNTS"

      echo ""
    fi
  fi
}

# ── Header ─────────────────────────────────────────────────────────────────
echo -e "${BLD}══════════════════════════════════════════════════════════════${RST}"
echo -e "${BLD}  Legacy DEMO / HealthBridge Reference Scanner${RST}"
echo -e "${BLD}  Repository: $(basename "$REPO_ROOT")${RST}"
echo -e "${BLD}  Date: $(date '+%Y-%m-%d %H:%M:%S')${RST}"
echo -e "${BLD}══════════════════════════════════════════════════════════════${RST}"
echo ""

# ── Run all pattern scans ─────────────────────────────────────────────────

echo -e "${BLD}── Project Names ──${RST}"
scan_pattern "PROJECT_NAME" "[Hh]ealth[Bb]ridge" "HealthBridge project name"
scan_pattern "PROJECT_NAME" "Health Bridge" "HealthBridge project name (space-separated)"

echo -e "${BLD}── Agent Prefix / Extension ID ──${RST}"
scan_pattern "PROJECT_NAME" "@hb-" "@hb- agent prefix (DEMO default)"
scan_pattern "PROJECT_NAME" "@hb " "@hb agent prefix without dash (e.g., 'type @hb in chat')"
scan_pattern "PROJECT_NAME" "hb-qa-agents" "hb-qa-agents extension ID (DEMO default)"
scan_pattern "PROJECT_NAME" "hb-qa-" "hb-qa- chat participant ID prefix"

echo -e "${BLD}── Legacy Ticket Prefixes ──${RST}"
scan_pattern "TICKET_PREFIX" "HM-[0-9]" "HM-* ticket prefix (HealthBridge main)"
scan_pattern "TICKET_PREFIX" "HBP-[0-9]" "HBP-* ticket prefix (HealthBridge Portal)"
scan_pattern "TICKET_PREFIX" "HMM-[0-9]" "HMM-* ticket prefix (HealthBridge Mobile)"
scan_pattern "TICKET_PREFIX" "\bHBP-\\\*" "HBP-* wildcard prefix reference"
scan_pattern "TICKET_PREFIX" "\bHMM-\\\*" "HMM-* wildcard prefix reference"
scan_pattern "TICKET_PREFIX" "\bHM-\\\*" "HM-* wildcard prefix reference"

echo -e "${BLD}── Legacy Repository Names ──${RST}"
scan_pattern "REPO_NAME" "HealthBridge-Web" "HealthBridge-Web repository"
scan_pattern "REPO_NAME" "HealthBridge-Api" "HealthBridge-Api repository"
scan_pattern "REPO_NAME" "HealthBridge-Portal" "HealthBridge-Portal repository"
scan_pattern "REPO_NAME" "HealthBridge-Mobile" "HealthBridge-Mobile repository"
scan_pattern "REPO_NAME" "HealthBridge-E2E" "HealthBridge E2E test repository"
scan_pattern "REPO_NAME" "HealthBridge-Selenium" "HealthBridge Selenium repository"
scan_pattern "REPO_NAME" "HealthBridge-Claims" "HealthBridge Claims-Processing repository"
scan_pattern "REPO_NAME" "HealthBridge-Prescriptions" "HealthBridge Prescriptions-Api repository"

echo -e "${BLD}── Healthcare Code Patterns ──${RST}"
scan_pattern "DOMAIN_TERM" "HBException" "HBException class (HealthBridge error handling)"
scan_pattern "DOMAIN_TERM" "HBForm" "HBForm class (HealthBridge frontend)"
scan_pattern "DOMAIN_TERM" "HBModal" "HBModal class (HealthBridge frontend)"
scan_pattern "DOMAIN_TERM" "\bTenantID\b" "TenantID (HealthBridge multi-tenancy pattern)"
scan_pattern "DOMAIN_TERM" "IResourceDataNode" "IResourceDataNode (HealthBridge API pattern)"
scan_pattern "DOMAIN_TERM" "\bFHIR\b" "FHIR integration (healthcare API standard)"
scan_pattern "DOMAIN_TERM" "ClinicalValidator" "ClinicalValidator class (healthcare validation)"
scan_pattern "DOMAIN_TERM" "FORMAT_MEDICAL" "FORMAT_MEDICAL_CODE (healthcare validation constant)"
scan_pattern "DOMAIN_TERM" "\bICD-10\b" "ICD-10 medical code standard"
scan_pattern "DOMAIN_TERM" "\bCPT\b" "CPT medical code standard"
scan_pattern "DOMAIN_TERM" "\bDEA\b" "DEA (Drug Enforcement Administration)"
scan_pattern "DOMAIN_TERM" "QueryHandler\|CommandHandler" "CQRS pattern (HealthBridge data layer)"

echo -e "${BLD}── Healthcare Domain Terms ──${RST}"
scan_pattern "DOMAIN_TERM" "domain-prescriptions" "Reference to deleted prescriptions domain file"
scan_pattern "DOMAIN_TERM" "domain-patient-records" "Reference to deleted patient-records domain file"
scan_pattern "DOMAIN_TERM" "domain-staff-scheduling" "Reference to deleted staff-scheduling domain file"
scan_pattern "DOMAIN_TERM" "healthbridge-repository-dependencies" "Reference to deleted healthbridge dependencies file"
scan_pattern "DOMAIN_TERM" "\bprescriptions?\b" "Healthcare domain term: prescription(s)"
scan_pattern "DOMAIN_TERM" "\bpatients?\b" "Healthcare domain term: patient(s)"
scan_pattern "DOMAIN_TERM" "\bappointments?\b" "Healthcare domain term: appointment(s)"
scan_pattern "DOMAIN_TERM" "\bdiagnos[ei]s\b" "Healthcare domain term: diagnosis/diagnoses"
scan_pattern "DOMAIN_TERM" "\bclinical\b" "Healthcare domain term: clinical"
scan_pattern "DOMAIN_TERM" "\bpharmacy\b" "Healthcare domain term: pharmacy"
scan_pattern "DOMAIN_TERM" "\bmedications?\b" "Healthcare domain term: medication(s)"
scan_pattern "DOMAIN_TERM" "\bHIPAA\b" "Healthcare domain term: HIPAA"
scan_pattern "DOMAIN_TERM" "\bdoctors?\b" "Healthcare domain term: doctor(s)"
scan_pattern "DOMAIN_TERM" "\bnurses?\b" "Healthcare domain term: nurse(s)"

echo -e "${BLD}── DEMO Template References ──${RST}"
scan_pattern "DEMO_REF" "from DEMO" "DEMO template reference"
scan_pattern "DEMO_REF" "the DEMO" "DEMO template reference"
scan_pattern "DEMO_REF" "Clone the DEMO" "DEMO clone instruction"
scan_pattern "DEMO_REF" "DEMO template" "DEMO template reference"

echo -e "${BLD}── Legacy E2E / Mobile Frameworks ──${RST}"
scan_pattern "E2E_LEGACY" "Playwright" "Playwright test framework (DEMO default)"
scan_pattern "E2E_LEGACY" "Selenium" "Selenium test framework (DEMO default)"
scan_pattern "E2E_LEGACY" "WebdriverIO" "WebdriverIO test framework (DEMO default)"
scan_pattern "E2E_LEGACY" "\bFlutter\b" "Flutter mobile framework (DEMO default)"
scan_pattern "E2E_LEGACY" "\bDart\b" "Dart language (DEMO default)"
scan_pattern "E2E_LEGACY" "\b3 frameworks?\b" "Hardcoded '3 frameworks' count (should match actual E2E count)"
scan_pattern "E2E_LEGACY" "all 3 frameworks" "Hardcoded 'all 3 frameworks' count"
scan_pattern "E2E_LEGACY" "3 test automation" "Hardcoded '3 test automation frameworks' count"
scan_pattern "E2E_LEGACY" "4-row" "Hardcoded '4-row' E2E coverage table reference"

# ── Deleted file references check ─────────────────────────────────────────
echo -e "${BLD}── Deleted Files Still Referenced ──${RST}"
DELETED_FILES=(
  "context/domain-prescriptions.md"
  "context/domain-patient-records.md"
  "context/domain-staff-scheduling.md"
  "context/healthbridge-repository-dependencies.md"
  "HealthBridge.code-workspace"
)
DELETED_FOUND=0
for dfile in "${DELETED_FILES[@]}"; do
  basename_f=$(basename "$dfile")
  refs=$(grep -rl "${EXCLUDE_ARGS[@]}" "$basename_f" . 2>/dev/null | wc -l | tr -d ' ' || echo 0)
  if [ "$refs" -gt 0 ]; then
    exists_marker="${RED}DELETED${RST}"
    [ -f "$dfile" ] && exists_marker="${YEL}EXISTS${RST}"
    echo -e "  ${RED}✗${RST} ${basename_f}  →  referenced in ${refs} file(s)  [${exists_marker}]"
    DELETED_FOUND=$((DELETED_FOUND + refs))
  fi
done
[ "$DELETED_FOUND" -eq 0 ] && echo -e "  ${GRN}✓ No references to deleted files found${RST}"
echo ""

# ── Summary ────────────────────────────────────────────────────────────────
echo -e "${BLD}══════════════════════════════════════════════════════════════${RST}"
echo -e "${BLD}  SUMMARY${RST}"
echo -e "${BLD}══════════════════════════════════════════════════════════════${RST}"
echo ""
echo -e "  Total legacy references found: ${BLD}${TOTAL_HITS}${RST}"
echo ""

echo -e "  ${BLD}By category:${RST}"
for cat_name in "PROJECT_NAME:$CAT_PROJECT_NAME" "TICKET_PREFIX:$CAT_TICKET_PREFIX" \
                "REPO_NAME:$CAT_REPO_NAME" "DOMAIN_TERM:$CAT_DOMAIN_TERM" \
                "DEMO_REF:$CAT_DEMO_REF" "E2E_LEGACY:$CAT_E2E_LEGACY"; do
  name="${cat_name%%:*}"
  count="${cat_name##*:}"
  if [ "$count" -gt 0 ]; then
    echo -e "    ${RED}✗${RST} ${name}: ${count}"
  else
    echo -e "    ${GRN}✓${RST} ${name}: 0"
  fi
done
echo ""

# ── Most affected files ───────────────────────────────────────────────────
if [ -s "$FILECOUNTS" ]; then
  echo -e "  ${BLD}Most affected files (top 10):${RST}"
  sort "$FILECOUNTS" | uniq -c | sort -rn | head -10 | while read -r count file; do
    echo -e "    ${RED}${count}${RST}  ${file}"
  done
  echo ""
fi

# ── Fix plan ───────────────────────────────────────────────────────────────
if $FIX_PLAN; then
  echo -e "${BLD}══════════════════════════════════════════════════════════════${RST}"
  echo -e "${BLD}  FIX PLAN${RST}"
  echo -e "${BLD}══════════════════════════════════════════════════════════════${RST}"
  echo ""
  echo -e "  ${BLD}Priority 1 — Instruction files (agents read these):${RST}"
  echo -e "    • .cursorrules — Stale DEMO copy with extensive HealthBridge refs."
  echo -e "      Either delete (if .claude/CLAUDE.md is authoritative) or fully update."
  echo -e "    • .github/copilot-instructions.md — Remove HBP-*/HMM-* prefixes,"
  echo -e "      healthcare domain refs, E2E coverage tables."
  echo ""
  echo -e "  ${BLD}Priority 2 — Context files:${RST}"
  echo -e "    • context/README.md — Remove links to deleted domain files."
  echo -e "    • context/e2e-test-coverage-map.md — Remove HMM-* reference."
  echo -e "    • context/domain-context-template.md — Update example to ePayslip domain."
  echo ""
  echo -e "  ${BLD}Priority 3 — Agent definitions:${RST}"
  echo -e "    • agents/vscode-chat-participants/acceptance-tests.md"
  echo -e "    • agents/vscode-chat-participants/requirements-analysis.md"
  echo -e "    → Remove references to deleted domain files."
  echo ""
  echo -e "  ${BLD}Priority 4 — Documentation & reports:${RST}"
  echo -e "    • README.md — Replace DEMO bootstrap refs, remove healthcare examples."
  echo -e "    • CHANGELOG.md — Remove healthcare domain entries, old ticket prefixes."
  echo -e "    • reports/code-review/HM-14200-feedback.json — Delete or archive."
  echo ""
fi

# ── Exit code ──────────────────────────────────────────────────────────────
if [ "$TOTAL_HITS" -gt 0 ]; then
  echo -e "${RED}${BLD}RESULT: ${TOTAL_HITS} legacy references found. Cleanup needed.${RST}"
  exit 1
else
  echo -e "${GRN}${BLD}RESULT: Clean — no legacy DEMO references found.${RST}"
  exit 0
fi
