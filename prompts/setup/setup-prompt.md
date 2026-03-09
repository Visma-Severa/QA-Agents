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

**Q1.2** — GitHub organization URL
```
What is your GitHub organization URL?
This is used in setup scripts to clone repositories.
Example: https://github.com/acme-corp
```

**Q1.3** — Agent chat prefix
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
List your core application repositories.
These are your main product repos (frontend, backend, mobile, etc.).
One per line, empty line when done.
```

**Q3.2** — Microservice API repositories
```
List your microservice/API repositories (if any).
One per line, empty line when done. Type "none" if not applicable.
```

**Q3.3** — E2E test automation repositories
```
List your E2E test automation repositories (if any).
One per line, empty line when done. Type "none" if not applicable.
```

**Q3.4** — For each repository, ask:
```
<repo-name>:
  Technology? (e.g., "C# / .NET Core", "TypeScript / React", "Python / Django")
  Default branch? (main / master / develop)
```

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
GitHub Org:     <url>
Agent Prefix:   @<prefix>-*
Workspace File: <name>.code-workspace

Ticket Prefixes:
  <PREFIX-1>-* → <repo1>, <repo2>
  <PREFIX-2>-* → <repo3>

Repositories (<count> total):
  Core:          <list>
  Microservices: <list>
  E2E Tests:     <list>

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
| `HealthBridge` | `<project-name>` | All files (case-sensitive) |
| `healthbridge` | `<project-name-lowercase>` | URLs, extension IDs |
| `@hb-` | `@<prefix>-` | Agent definitions, package.json, extension.ts |
| `hb-qa-agents` | `<prefix>-qa-agents` | package.json, extension.ts, commands |
| `hb-qa-` | `<prefix>-` | Chat participant IDs |
| `HM-14200` | `<first-prefix>-1001` | Example ticket IDs |
| `HBP-5001` | `<second-prefix>-2001` (if exists) | Example ticket IDs |
| `HMM-3200` | `<third-prefix>-3001` (if exists) | Example ticket IDs |
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

**`setup/setup.sh` and `setup/setup.ps1` — REPOS array:**
Replace the array with collected repositories:
```bash
REPOS=(
    # Core application repositories
    "<repo-1>"
    "<repo-2>"
    # Microservice API repositories
    "<repo-3>"
    # Test automation repositories
    "<repo-4>"
    # QA Agents repository
    "DEMO-QA-Agents"
)

GITHUB_ORG="<github-org-url>"
```

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
Skeleton files that need your data:
  ⚠ context/domain-<name>.md — add business rules and regulations
  ⚠ context/<project>-repository-dependencies.md — map service dependencies
  ⚠ context/historical-bugfix-patterns.md — add real bugfix data over time
  ⚠ context/jira-field-mappings.md — map file paths to JIRA components
  ✓ context/e2e-test-coverage-map.md — framework columns populated, mark coverage
```

---

## What This Agent Does NOT Change

These files contain generic analysis logic and should not be modified:

| File / Folder | Why Preserve |
|---------------|-------------|
| `prompts/*/` prompt and template files | Generic analysis logic, scoring models, report formats |
| `prompts/requirements-analysis/requirements-analysis-template.md` | 7/10 scoring gate is project-agnostic |
| `prompts/bug-report/severity-criteria.md` | Generic severity definitions |
| `context/domain-context-template.md` | Template for creating new domain files |
| `context/code-review-false-positive-prevention.md` | Update incrementally, not during setup |

---

## Re-Run Behavior

If the setup agent is run again on an already-customized project:
1. Detect that "HealthBridge" references are absent
2. Ask: "This project appears already customized for [detected name]. Do you want to reconfigure? This will overwrite current settings."
3. If yes, proceed with full flow
4. If no, offer to run only Phase 3 (verification) to check consistency
