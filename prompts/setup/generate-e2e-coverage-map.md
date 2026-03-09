# Generate E2E Test Coverage Map

**Purpose:** Analyze all E2E test repositories in the workspace and generate `context/e2e-test-coverage-map.md` with actual functional area coverage per framework.

---

## When to Run

- After initial project setup (bootstrap + @setup agent)
- When new E2E test suites are added
- When functional areas are added or reorganized
- Periodically (quarterly) to catch new tests added since last scan

---

## Input

No input required — the prompt scans all test repositories in the workspace.

**Optional input:** User can provide a list of functional areas to check coverage for.

---

## Execution Steps

### Step 1: Identify E2E Test Repositories

Read the workspace configuration (`.claude/CLAUDE.md` or `.code-workspace`) to find test repositories. Alternatively, look for repositories with test-related names or structures:

```bash
# Look for test repositories by naming convention
ls -d *Test* *test* *E2E* *e2e* *Selenium* *selenium* *Playwright* *playwright* *Mobile-Test* 2>/dev/null
```

For each test repository, identify:
- Repository name
- Framework (Selenium, Playwright, Cypress, WebdriverIO, Appium, etc.)
- Language (Python, TypeScript, JavaScript, C#, Java, etc.)
- Test file extension (`*.py`, `*.spec.ts`, `*.test.js`, `*.cs`, etc.)
- Default branch

### Step 2: Scan Test Directories and Files

For each test repository, fetch latest and list the test structure:

```bash
git fetch origin
# List all test directories (top-level organization)
git ls-tree -d --name-only origin/main

# List all test files
git ls-tree -r --name-only origin/main -- "*.py" "*.spec.ts" "*.test.ts" "*.test.js" "*.cs"
```

Group tests by directory/module. For each module, record:
- Module name (directory)
- Test file names
- Key test names (extract from file names or test method names)

### Step 3: Identify Functional Areas

Extract functional areas from the test organization. Functional areas are the business domains tested:

```bash
# Get all top-level test directories (these usually map to functional areas)
git ls-tree -d --name-only origin/main -- "Tests/" "tests/" "test/" "specs/"

# Search for describe/test blocks to identify what's being tested
git grep -n "describe(\|it(\|test(\|def test_\|class Test\|\[Test\]\|\[Fact\]" origin/main -- "*.py" "*.spec.ts" "*.test.js" "*.cs"
```

Also check the application repositories for functional areas:
- Main navigation/routing (what modules exist in the app)
- Controller/API endpoint structure
- Database table groupings

### Step 4: Build Coverage Matrix

For each functional area, check which test frameworks have coverage:

```bash
# For each functional area keyword, search across all test repos
cd <test-repo> && git grep -l "<keyword>" origin/main -- "*.<test-ext>"
```

Record:
- Functional area name
- For each framework: Yes (tests found) / No (no tests found)
- Warning flag if a functional area has NO coverage in ANY framework

### Step 5: Extract Detailed Module Information

For each framework with coverage, extract:
- Module/directory name
- Key test files
- Search keywords (for agents to find relevant tests later)

### Step 6: Generate the Output File

Create `context/e2e-test-coverage-map.md` following the structure of the demo file (`context/e2e-test-coverage-map.md`).

**Required sections:**

1. **Header** — Version, last updated date, purpose statement
2. **CRITICAL rule** — "Use FUNCTIONAL AREA, NOT Branch Prefix" explanation
3. **How to Use** — 4-step lookup process
4. **Quick Reference Table** — Functional areas vs frameworks matrix (Yes/No)
5. **Per-Framework Detailed Sections** — For each framework:
   - Repository name, language, file extension
   - Module table: Module, Test Folder, Key Test Files, Search Keywords
   - Search strategy command
6. **Coverage Table Format** — Standard format for agent reports
7. **Coverage Status Definitions** — Full / Partial / Gap / N/A
8. **Change Log** — Date, change description, source

**Flags:**
- Mark functional areas with zero coverage across ALL frameworks: `> WARNING — Manual-Only Area`
- Mark frameworks with very sparse coverage: note in the detailed section

---

## Output

```
context/e2e-test-coverage-map.md
```

---

## Quality Checks

After generating:
- Every functional area from the application should appear in the Quick Reference Table
- Every test repository should have a detailed section
- Search keywords should be specific enough to find relevant tests without false positives
- The Quick Reference Table should match the detailed sections (no contradictions)
- At least one "WARNING — Manual-Only Area" flag if any area has zero E2E coverage
- No placeholder values — use actual test file names and directories from the scan
