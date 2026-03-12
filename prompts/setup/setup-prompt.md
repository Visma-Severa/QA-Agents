# Project Setup — Interactive Flow

Analysis logic for the Setup Agent. For orchestration, see `agents/vscode-chat-participants/setup.md`.

---

## Context

This framework provides 7 QA AI agents designed for multi-repository projects. All project-specific references (repository names, ticket prefixes, agent identifiers, domain knowledge) must be replaced before the agents can work with a new project.

The framework is ~70% generic (prompts, templates, scoring models, analysis logic) and ~30% project-specific (names, prefixes, repos, domains). This setup flow collects the project-specific 30% and applies it systematically.

---

## Phase 1: Interactive Questions

Ask questions one group at a time. After each group, summarize what was collected before moving to the next.

### Group 1: Project Identity

```
Welcome to QA Agents Setup!

I'll help you adapt this framework to your project.
This takes about 5 minutes — I'll ask a few questions,
then update all configuration files automatically.

Let's start with the basics.
```

**Q1.1** — Project name
```
What is your project name?
This will be used in file names, extension title, and documentation.
Example: "Acme Platform", "Falcon ERP", "MediTrack"
```

**Q1.2** — Agent chat prefix
```
What prefix do you want for VS Code chat agents?
Keep it short (2-4 chars). This creates agents like @<prefix>-code-review.
Example: "acme", "fal", "mt"
```

### Group 2: JIRA Configuration

**Q2.1** — Ticket prefixes
```
What JIRA ticket prefixes does your project use?
Enter each prefix on a separate line (without the dash).
Empty line when done.

Example:
  ACME
  ACMP
```

**Q2.2** — For each prefix, ask:
```
Which repositories use the prefix "<PREFIX>-*"?
(comma-separated)
```

### Group 3: Repository Inventory

**Q3.1** — Core application repositories
```
List your core application repositories (product repos).
For each repo, provide the clone URL (HTTPS or SSH).
One per line, empty line when done.

Example:
  https://github.com/acme-corp/acme-backend.git
  git@github.com:acme-corp/acme-frontend.git
```

**Q3.2** — Microservice API repositories
```
List your microservice/API repositories (if any).
One clone URL per line, empty line when done. Type "none" if not applicable.
```

**Q3.3** — E2E test automation repositories
```
List your E2E test automation repositories (if any).
One clone URL per line, empty line when done. Type "none" if not applicable.
```

**Q3.4** — For each repository, ask:
```
<repo-name>:
  Technology? (e.g., "C# / .NET Core", "TypeScript / React", "Python / Django")
  Default branch? (main / master / develop)
```

**Note:** The repo name is extracted from the clone URL (e.g., `acme-backend` from `https://github.com/acme-corp/acme-backend.git`). Repos can be in different GitHub organizations.

### Group 4: E2E Test Frameworks

**Q4.1** — Frameworks used
```
What E2E test frameworks do you use?
Comma-separated. Example: "Playwright, Selenium, Cypress, Appium"
Type "none" if no E2E tests yet.
```

**Q4.2** — For each framework, ask:
```
Which repository contains <framework> tests?
```

### Group 5: Business Domains

**Q5.1** — Functional domains
```
What are your main business/functional domains?
These become domain context files with regulatory rules and business logic
that help agents understand your product area.

One per line, empty line when done.
Example:
  Payments & Billing
  User Management
  Inventory
  Order Processing
```

### Group 6: Development Context Docs (Optional)

**Q6.1** — Architectural docs
```
Do any of your repositories have architectural or development guideline
docs that QA agents should reference during analysis?

If yes, provide the path pattern (e.g., "Acme-Backend/docs/AGENTS-*.md").
If no, type "none" — agents will work without them.
```

---

## Phase 1 Summary

After all questions, present a summary:

```
──── Configuration Summary ────

Project:        <name>
Agent Prefix:   @<prefix>-*
Workspace File: <name>.code-workspace

Ticket Prefixes:
  <PREFIX-1>-* → <repo1>, <repo2>
  <PREFIX-2>-* → <repo3>

Repositories (<count> total):
  Core:          <name> (<clone-url>)
  Microservices: <name> (<clone-url>)
  E2E Tests:     <name> (<clone-url>)

E2E Frameworks:
  <framework1> → <repo>
  <framework2> → <repo>

Business Domains: <list>

Dev Context Docs: <path or "none">

────────────────────────────────

Shall I proceed with updating all files? (yes / no / edit)
```

If user says "edit", ask which group to revisit. If "no", save answers and exit gracefully. If "yes", proceed to Phase 2.

---

## Phase 2: File Update Logic

### Update Strategy

For each file, use find-and-replace with the collected configuration. The replacements are systematic:

### 2.1 Global Find-and-Replace Pairs

Build these replacement pairs from the collected answers:

| Find | Replace With | Scope |
|------|-------------|-------|
| `HealthBridge` | `<project-name>` | All files including agents, prompts, and templates (case-sensitive) |
| `healthbridge` | `<project-name-lowercase>` | URLs, extension IDs |
| `@hb-` | `@<prefix>-` | Agent definitions, package.json, extension.ts, prompts |
| `hb-qa-agents` | `<prefix>-qa-agents` | package.json, extension.ts, commands |
| `hb-qa-` | `<prefix>-` | Chat participant IDs |
| `HM-14200` | `<first-prefix>-1001` | Example ticket IDs (all files) |
| `HBP-5001` | `<second-prefix>-2001` (if exists) | Example ticket IDs (all files) |
| `HMM-3200` | `<third-prefix>-3001` (if exists) | Example ticket IDs (all files) |
| `HealthBridge.code-workspace` | `<project-name>.code-workspace` | Setup scripts, README |

### 2.2 Structured Updates (Not Simple Find-Replace)

These require rebuilding sections, not just string replacement:

**`.claude/CLAUDE.md` — Multi-Repository Workspace table:**
Replace the entire table with repos from Phase 1:
```markdown
| Branch Prefix | Repository | Technology | Base Branch |
|---------------|------------|------------|-------------|
| `<PREFIX-1>-*` | `<repo-1>` | <tech-1> | `<branch-1>` |
...
```

**`.claude/CLAUDE.md` — JIRA Ticket ID section:**
Replace prefix table and examples with collected data.

**`setup/setup.sh` and `setup/setup.ps1` — REPOS associative array:**
Replace the array with collected repositories using clone URLs:
```bash
# Associative array: repo-name=clone-url
REPOS=(
    # Core application repositories
    "repo-1=https://github.com/org/repo-1.git"
    "repo-2=git@github.com:org/repo-2.git"
    # Microservice API repositories
    "repo-3=https://github.com/other-org/repo-3.git"
    # Test automation repositories
    "repo-4=https://github.com/org/repo-4.git"
)
```
This allows repos from different GitHub organizations to be cloned in one setup.

**`.code-workspace` file:**
Rename file and replace folder entries.

**`.vscode-extension/package.json` — chatParticipants array:**
Rebuild with new prefix and correct agent IDs.

**`.vscode-extension/src/extension.ts`:**
- Update `AGENTS` array IDs and prompt file names
- Update `findRepoRoot()` to check for one of the new core repo names
- Update activation message

**`README.md`:**
- Update project name throughout
- Rebuild repository tables
- Update setup command examples
- Update agent usage examples with new prefix and ticket IDs

**`prompts/` — All prompt and template files:**

The global find-and-replace (Section 2.1) handles most references automatically. Additionally, these files need structured updates:

| File | Structured Changes |
|------|-------------------|
| `prompts/bug-report/bug-report-prompt.md` | Rebuild repo detection table with repos from Phase 1 |
| `prompts/bug-report/bug-report-template.md` | Rebuild E2E coverage table with frameworks and repos from Phase 1 |
| `prompts/code-review-qa/code-review-template.md` | Update E2E repo paths to match Phase 1 test repos |
| `prompts/code-review-qa/code-review-qa.md` | Update project description and technology stack |
| `prompts/dev-estimation/dev-estimation-template.md` | Rebuild per-repo sections (2.1, 2.2, etc.) using repos from Phase 1 with their technologies |
| `prompts/release-assessment/release-assessment-template.md` | Rebuild E2E test sections with framework names and repos from Phase 1 |
| `prompts/release-assessment/release-assessment-prompt.md` | Update project description |
| `prompts/requirements-analysis/requirements-analysis-template.md` | Rebuild cross-repo impact table with repos from Phase 1 |

**`agents/vscode-chat-participants/` — All agent definition files:**

The global find-and-replace handles project name, prefix, and ticket IDs. No additional structured updates needed beyond Section 2.1.

### 2.3 Context File Generation

**Domain context files** — For each domain from Q5.1:
1. Read `context/domain-context-template.md`
2. Replace `[Area Name]` with domain name
3. Replace trigger keywords placeholder with domain-relevant terms
4. Save as `context/domain-<slugified-name>.md`
5. Content sections remain as template placeholders — user fills in later

**Repository dependencies** — Create `context/<project-lowercase>-repository-dependencies.md`:
```markdown
# <Project> Repository Dependencies

| Provider | Consumer | Integration | Shared DB |
|----------|----------|-------------|-----------|
| <repo-1> | <repo-2> | [describe] | [yes/no] |
...
(Fill in actual dependencies)
```

**E2E coverage map** — Create/update `context/e2e-test-coverage-map.md`:
```markdown
# E2E Test Coverage Map

| Functional Area | <framework-1> | <framework-2> |
|-----------------|---------------|---------------|
| <domain-1>      | [ ]           | [ ]           |
| <domain-2>      | [ ]           | [ ]           |
...
(Mark with [x] as you add test coverage)
```

**Historical bugfix patterns** — Create `context/historical-bugfix-patterns.md`:
```markdown
# Historical Bugfix Patterns

Track your hotfix patterns here. After analyzing real bugfixes,
update percentages and detection focus per repository type.

## <tech-1> Repositories (<repo-list>)

| Pattern | % | Detection Focus |
|---------|---|-----------------|
| Edge Cases | ?% | [Add after analyzing real hotfixes] |
| NULL Handling | ?% | [Add after analyzing real hotfixes] |
| Logic Errors | ?% | [Add after analyzing real hotfixes] |
...
```

**JIRA field mappings** — Create `context/jira-field-mappings.md`:
```markdown
# JIRA Field Mappings

Auto-detect JIRA ticket components from file paths.

| File Path Pattern | JIRA Component |
|-------------------|---------------|
| <repo-1>/src/** | [Component name] |
| <repo-2>/src/** | [Component name] |
...
(Fill in as you learn your component structure)
```

### 2.4 Report Directory Creation

Create all report subdirectories:
```
reports/acceptance-tests/
reports/bug-report/
reports/bugfix-rca/
reports/code-review/
reports/feedback/
reports/release-analysis/
reports/requirements-analysis/
```

Add `.gitkeep` to each empty directory.

### 2.5 No-E2E Mode

**When Q4.1 answer is "none" (no E2E test frameworks), apply the following adjustments:**

#### 2.5.1 Context File: `context/e2e-test-coverage-map.md`

Generate a simplified version instead of the full framework-based coverage map:

```markdown
# E2E Test Coverage Map

**Status:** No E2E test automation is currently configured for this project.

## Functional Areas

Reference table for manual test planning. When E2E automation is added later, use this to track coverage.

| Functional Area | Manual Test Priority | Notes |
|-----------------|---------------------|-------|
| <domain-1> | High / Medium / Low | [Add notes] |
| <domain-2> | High / Medium / Low | [Add notes] |
...

## Adding E2E Automation Later

When you add E2E test automation:
1. Re-run setup (`@<prefix>-setup`) and provide framework details for Q4.1/Q4.2
2. Or manually update this file with framework columns and the CLAUDE.md E2E sections
3. Update report templates to use the framework-specific E2E coverage tables
```

#### 2.5.2 CLAUDE.md E2E Sections

Replace all framework-specific E2E instructions with no-E2E equivalents:

- **"E2E Framework Selection by Functional Area"** section — Replace with:
  ```
  **No E2E test automation repositories are configured for <project-name>.** E2E coverage analysis is not available.

  Report "N/A — No E2E automation configured" for all E2E coverage sections in every agent report.
  ```

- **"E2E Test Search Strategy"** section — Replace with:
  ```
  **No E2E test automation repositories are configured for <project-name>.** Skip all E2E search steps. Report "N/A — No E2E automation" in coverage tables.
  ```

- **"E2E Repository — Fetch Latest Before Coverage Analysis"** section — Replace with:
  ```
  **No E2E test automation repositories are configured.** Skip E2E fetch and coverage analysis steps. Report "N/A — No E2E automation configured" for all E2E coverage sections.
  ```

- Remove E2E test repositories from the **Multi-Repository Workspace** table (keep only application repos).

#### 2.5.3 Report Templates — E2E Coverage Tables

In ALL template files that contain the 4-row framework coverage table (Selenium UI / Selenium Integration / Playwright / Mobile), replace with a conditional block:

```markdown
**If E2E automation is configured:**
[4-row framework table populated from collected answers]

**If NO E2E automation (Q4.1 = "none"):**
> N/A — No E2E test automation configured for this project.
```

Affected template files:
- `prompts/code-review-qa/code-review-template.md` (Section 4.2)
- `prompts/bugfix-rca/bugfix-rca-e2e-template.md` (Section 2)
- `prompts/acceptance-tests/acceptance-tests-template.md` (E2E Coverage section)
- `prompts/bug-report/bug-report-template.md` (E2E section)

#### 2.5.4 Prompt Validation Checklists

In prompts that validate "Coverage table has 4 rows", add a conditional:
- If E2E configured: "Coverage table has N rows (one per framework)"
- If no E2E: "E2E section shows N/A note"

Affected:
- `prompts/bugfix-rca/bugfix-rca-prompt.md`
- `prompts/bug-report/bug-report-prompt.md`

#### 2.5.5 Acceptance Tests Prompt

In `prompts/acceptance-tests/acceptance-tests-prompt.md`, the "E2E Coverage Analyzer" sub-agent section should note: "If `context/e2e-test-coverage-map.md` indicates no E2E automation, skip the full scan and report 'N/A — No E2E automation configured' for all coverage sections."

---

## Phase 3: Verification Logic

### 3.1 Leftover Reference Scan

Search all files (excluding `agents/vscode-chat-participants/setup.md` and `prompts/setup/`) for:
- `HealthBridge` (case-sensitive)
- `@hb-` (old prefix)
- `hb-qa-agents` (old extension ID)
- `HM-14200`, `HBP-5001`, `HMM-3200` (old example tickets)

Report format:
```
Leftover references found:
  ⚠ <file>:<line> — "<matched text>"
  ⚠ <file>:<line> — "<matched text>"

OR

✓ No leftover references found — clean!
```

### 3.2 Consistency Validation

| Check | Method | Expected |
|-------|--------|----------|
| Agent prefix | Read all 7 agent .md files, extract `@<prefix>-` from header | All match collected prefix |
| Package.json IDs | Read chatParticipants array | All IDs start with collected prefix |
| Extension.ts IDs | Read AGENTS array | All IDs match package.json |
| Workspace folders | Parse .code-workspace JSON | Folder count = repo count |
| Setup script repos | Parse REPOS array in setup.sh | Same repos as workspace file |
| Context file refs | Read CLAUDE.md Shared Context table | All referenced files exist |

### 3.3 Skeleton File Report

List all context files that contain template placeholders:
```
Skeleton files created — Phase 4 will populate these with real data:
  → context/domain-<name>.md
  → context/<project>-repository-dependencies.md
  → context/historical-bugfix-patterns.md
  → context/jira-field-mappings.md
  → context/e2e-test-coverage-map.md

Proceeding to Phase 4: Context Customization...
```

---

## Phase 4: Context Customization

**This phase runs interactively after verification.** The agent guides the user through populating context files with real project data instead of leaving empty skeletons.

### 4.0 Clone Repositories

Before context generation, repos must be available for scanning.

```
Phase 3 complete. Now let's populate your context files with real project data.

First, I need your repositories cloned so I can scan them.
Shall I run the setup script now?

  ./setup/setup.sh          (macOS/Linux)
  .\setup\setup.ps1         (Windows)
```

Wait for completion. If repos are already cloned, skip to 4.1.

### 4.1 Repository Dependencies (Auto-Generated)

Execute `prompts/setup/generate-repository-dependencies.md`:

```
Scanning your repositories for API connections, shared databases,
and package dependencies...
```

- Scan all cloned repos for: HTTP client calls, DB connection strings, shared NuGet/npm packages
- Generate `context/<project>-repository-dependencies.md` with actual data
- Show summary and ask user to confirm or adjust

### 4.2 E2E Coverage Map (Auto-Generated)

**Skip if user answered "none" for E2E frameworks in Phase 1.**

Execute `prompts/setup/generate-e2e-coverage-map.md`:

```
Scanning your test repositories for E2E coverage by functional area...
```

- Scan test repos, group test files by functional area
- Generate `context/e2e-test-coverage-map.md` with actual coverage
- Show summary to user

### 4.3 Historical Bugfix Patterns (Conditional)

```
Do your repositories have hotfix history I can analyze?
This helps agents predict which code patterns are most likely to cause bugs.
I need roughly 10+ hotfixes for meaningful patterns.

  1. Yes, scan my repos now
  2. Skip — I'll run this later when we have more history
```

If 1: Execute `prompts/setup/generate-bugfix-patterns.md`
If 2: Leave skeleton, note in completion summary

### 4.4 JIRA Field Mappings (Guided)

```
Let me scan your repository structures to suggest JIRA component mappings.
These help agents auto-populate bug report fields from file paths.
```

- Scan repo directory structures (top-level folders, namespaces)
- Propose mappings: `<repo>/src/Payments/** → Payments component`
- Ask user to confirm or adjust each mapping
- Write `context/jira-field-mappings.md`

### 4.5 Domain Context Files (Interactive)

For each domain skeleton created in Phase 2, ask:

```
Let's fill in domain knowledge for: [Domain Name]

1. What are the main business rules for [domain]?
   (e.g., "prescription refills require doctor approval")

2. Are there regulatory or compliance requirements?
   (e.g., HIPAA, GDPR, SOX, industry-specific rules)

3. What are the common edge cases or tricky scenarios?
   (e.g., "leap year dates", "currency rounding", "timezone handling")

4. What external system integrations does this domain have?
   (e.g., "bank API for payments", "tax authority reporting")
```

- Write answers into `context/domain-<name>.md`
- If user says "skip", leave as skeleton

### 4.6 False Positive Prevention (Optional)

```
Do you have any known code patterns that look suspicious but are actually safe?
These prevent agents from flagging false issues during code review.

Examples:
  - "We use raw SQL in Reports/ — it's parameterized via our ORM wrapper"
  - "Empty catch blocks in BackgroundJobs/ are intentional — errors logged upstream"

Type your patterns (one per line), or "skip" to fill in later.
```

If provided: Update `context/code-review-false-positive-prevention.md`
If skipped: Leave existing default file

---

## What This Agent Does NOT Change

These aspects of files should be preserved — only project-specific references (names, repos, prefixes) are replaced, not the underlying logic:

| What to Preserve | Examples |
|-----------------|----------|
| Scoring models and thresholds | 7/10 requirements gate, severity criteria scales |
| Analysis methodology and checklists | Code review checklist items, RCA analysis steps |
| Report section structure and formatting | Section headers, markdown layout, collapsible sections |
| Template placeholder syntax | `{placeholder}`, `[X.X hours]`, `High/Medium/Low` |
| `context/domain-context-template.md` | Template for creating new domain files — not a project file |
| `prompts/setup/` | Setup agent's own files — excluded from find-and-replace |

---

## Re-Run Behavior

If the setup agent is run again on an already-customized project:
1. Detect that "HealthBridge" references are absent
2. Ask: "This project appears already customized for [detected name]. Do you want to reconfigure? This will overwrite current settings."
3. If yes, proceed with full flow
4. If no, offer to run only Phase 3 (verification) or Phase 4 (context customization) individually
