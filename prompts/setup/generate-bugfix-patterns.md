# Generate Historical Bugfix Patterns

**Purpose:** Analyze git history across all repositories to identify hotfix/bugfix patterns, categorize root causes, calculate percentages per repository type, and generate `context/historical-bugfix-patterns.md`.

---

## When to Run

- After initial project setup — analyze all available hotfix history (up to 100 hotfixes)
- Quarterly to update percentages with new hotfix data
- After major production incidents to capture new pattern categories

---

## Input

**Optional:** User can specify:
- Time range (default: last 12 months)
- Maximum hotfixes to analyze (default: 100 — enough for reliable category percentages)
- Hotfix branch naming convention (default: searches for `hotfix`, `bugfix`, `fix`, `patch` in branch names and commit messages)
- Specific repositories to analyze (default: all repos in workspace)

**IMPORTANT:** The goal is to analyze a large enough sample (up to 100 hotfixes) to produce **aggregated categories with reliable percentages** — NOT to list individual issues. Each hotfix is classified into a root cause category, and the output shows category totals.

---

## Execution Steps

### Step 1: Find Hotfix Branches and Commits

For each repository in the workspace, fetch latest and search for up to **100 hotfix-related branches and commits** (across all repos combined):

```bash
git fetch origin

# Find hotfix/bugfix branches
git branch -r --list "*hotfix*"
git branch -r --list "*bugfix*"
git branch -r --list "*fix*"
git branch -r --list "*patch*"

# Find hotfix commits on the default branch (merged hotfixes) — get up to 100
git log origin/main --oneline --grep="hotfix" --since="<start-date>" -100
git log origin/main --oneline --grep="bugfix" --since="<start-date>" -100
git log origin/main --oneline --grep="fix" --since="<start-date>" -100

# Also check for revert commits (often indicate production issues)
git log origin/main --oneline --grep="revert" --since="<start-date>" -50
```

**Report progress:** "Found X hotfix branches and Y hotfix commits across Z repositories"

### Step 2: Analyze Each Hotfix

For each hotfix branch or commit found, analyze the actual code changes:

```bash
# For branches: get the diff against the base branch
git diff origin/main...origin/<hotfix-branch> --stat
git diff origin/main...origin/<hotfix-branch> -- "*.cs" "*.ts" "*.py" "*.dart" "*.vb"

# For merged commits: show the actual changes
git show <commit-hash> --stat
git show <commit-hash> -- "*.cs" "*.ts" "*.py" "*.dart" "*.vb"
```

For each hotfix, determine:

1. **What was the bug?** (read commit message + code diff)
2. **Root cause category** — classify into one of these categories:

| Category | Indicators in Code Diff |
|----------|------------------------|
| **Edge Cases** | Added checks for empty/null/zero/boundary values, added `if` guards for special conditions |
| **NULL Handling** | Added null checks, `?.` operators, `?? default`, `FirstOrDefault()` null guards |
| **Logic/Condition Errors** | Changed `&&` to `\|\|`, fixed comparison operators, added missing `else` branch, off-by-one fix |
| **Permission/Authorization** | Added role/permission checks, fixed access level validation |
| **Data Validation** | Added input validation, range checks, format validation |
| **Configuration/DI Errors** | Fixed DI registration, corrected service lifetimes, updated config values |
| **Database/ORM Issues** | Fixed query, added `.Include()`, corrected column type, fixed migration |
| **Concurrency/Race Conditions** | Added locks, fixed async/await, added retry logic, fixed transaction scope |
| **Type Casting Errors** | Fixed type conversion, changed cast method, corrected data type |
| **Missing Implementation** | Replaced TODO/stub with actual implementation, added missing feature |
| **State Management** | Fixed lifecycle issues, added disposal, fixed async state |
| **Error Handling** | Added try/catch, improved error propagation, added retry |
| **UI Event/Lifecycle** | Fixed event handlers, component lifecycle, rendering issues |
| **CI/CD & Deployment** | Fixed build script, Docker config, deployment pipeline |

3. **Which files were changed?** (module/area affected)
4. **How it could have been caught** (code review, unit test, E2E test, requirements)

### Step 3: Group by Repository Type

Group repositories by their technology stack and architectural role:

| Grouping Criteria | Examples |
|-------------------|---------|
| Monolith / Web backend | Large ASP.NET/Django/Rails apps with multiple modules |
| Microservice APIs | Individual .NET Core/Node.js/Python API services |
| Frontend (SPA) | React, Angular, Vue applications |
| Mobile | Flutter, React Native, native iOS/Android |
| Background services / Workers | Queue consumers, scheduled jobs, ETL pipelines |
| Test automation | Selenium, Playwright, Cypress repos (usually no hotfixes) |

Repositories with the same technology AND architectural role share a pattern table.

### Step 4: Calculate Percentages

For each repository group:

1. Count total hotfixes analyzed
2. Count hotfixes per category
3. Calculate percentage: `(category count / total) * 100`, rounded to nearest integer
4. Sort categories by percentage (highest first)
5. Keep top 6-8 categories (merge rare categories below 5% into the nearest match)

**Sample size and confidence:**
- **50+ hotfixes:** High confidence — full pattern table with reliable percentages
- **20-49 hotfixes:** Good confidence — full pattern table with percentages
- **10-19 hotfixes:** Moderate confidence — pattern table marked as `[Preliminary — based on <N> hotfixes]`
- **< 10 hotfixes:** Low confidence — list observed categories without percentages, note insufficient data

**Target:** Analyze up to 100 hotfixes per repository group for the most reliable percentages.

### Step 5: Write Detection Focus

For each pattern in each table, add a "Detection Focus" column with **specific examples from your codebase** — not generic descriptions. Reference actual:
- File patterns (e.g., "Controllers/*Controller.cs missing authorization attribute")
- Code patterns (e.g., "`FirstOrDefault()` on patient query without null check")
- Architectural patterns (e.g., "API endpoint added without corresponding permission in middleware")

### Step 6: Generate the Output File

**CRITICAL: The output is AGGREGATED CATEGORIES, not a list of individual issues.**

Each row in the pattern table represents a **root cause category** (e.g., "Edge Cases", "NULL Handling") with a percentage calculated from all analyzed hotfixes — NOT individual bug tickets.

| WRONG (individual issues) | CORRECT (aggregated categories) |
|---------------------------|--------------------------------|
| VKP-001 Decimal rounding — 10% | Edge Cases — 26% |
| VKP-002 Timezone handling — 10% | NULL Handling — 18% |
| VKP-005 Null reference — 10% | Logic/Condition Errors — 16% |

Create `context/historical-bugfix-patterns.md` following the structure of the demo file.

**Required sections:**

1. **Header** — Canonical source of truth statement
2. **Repository-to-Pattern Routing** — Table mapping each repository to its pattern table and branch prefix
3. **One Pattern Table per Repository Type** — Each with:
   - Section heading: `## <Type> Patterns (<Repository List>)`
   - Data source note: `Based on RCA of <N> production bugfixes:`
   - Table: Pattern, %, Detection Focus
   - Key differences note (if applicable — what makes this repo type unique)
4. **How Agents Use This File** — Section explaining usage per agent type:
   - Code Review: check each pattern against code changes
   - Release Analysis: apply per-PR pattern tables
   - Requirements Analysis: identify likely edge cases
5. **Output Templates** — Generic format for agent reports

---

## Output

```
context/historical-bugfix-patterns.md
```

---

## Quality Checks

After generating:
- Percentages in each table must sum to 100% (±2% for rounding)
- Every repository in the workspace should be mapped to a pattern table
- Detection Focus should contain project-specific examples, not generic descriptions
- Tables with fewer than 20 hotfixes should be marked as preliminary
- Each table should have 5-8 aggregated categories (not individual issues, not too broad)
- No individual ticket IDs should appear as pattern names — patterns are categories like "Edge Cases", "NULL Handling"
- The "How Agents Use This File" section should reference actual agent names from the project

---

## If No Hotfix History Exists

If the project is new or has no identifiable hotfix branches:

1. Generate a starter template with common categories and `?%` placeholders
2. Include instructions at the top: "Update percentages after analyzing your first 20+ production hotfixes (run this prompt again)"
3. Use industry-standard distributions as a starting point (clearly marked as estimates):

```markdown
## <Repository Type> Patterns (<Repos>)

> Starter template — update with real data after 10-15 hotfixes.

| Pattern | % | Detection Focus |
|---------|---|-----------------|
| Edge Cases | ?% | [Add after analyzing real hotfixes] |
| NULL Handling | ?% | [Add after analyzing real hotfixes] |
| Logic/Condition Errors | ?% | [Add after analyzing real hotfixes] |
| Permission/Authorization | ?% | [Add after analyzing real hotfixes] |
| Data Validation | ?% | [Add after analyzing real hotfixes] |
| Missing Implementation | ?% | [Add after analyzing real hotfixes] |
```
